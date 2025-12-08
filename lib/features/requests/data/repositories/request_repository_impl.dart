import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/db/daos/meta_dao.dart';
import '../../../../core/db/daos/request_dao.dart';
import '../../../../core/db/daos/sync_queue_dao.dart';
import '../../../../core/domain/repository_result.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/request_entity.dart';
import '../../domain/repositories/request_repository.dart';
import '../datasources/request_remote_datasource.dart';
import '../models/request_model.dart';

class RequestRepositoryImpl implements RequestRepository {
  final AppDatabase db;
  final RequestDao requestDao;
  final MetaDao metaDao;
  final SyncQueueDao syncQueueDao;
  final RequestRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final Logger logger;

  RequestRepositoryImpl({
    required this.db,
    required this.requestDao,
    required this.metaDao,
    required this.syncQueueDao,
    required this.remoteDataSource,
    required this.networkInfo,
    Logger? logger,
  }) : logger = logger ?? Logger();

  @override
  Stream<List<RequestEntity>> watchMyRequests({
    required String projectId,
    String? userId,
  }) {
    if (userId != null) {
      return requestDao
          .watchRequestsForUser(projectId, userId)
          .map((rows) => rows.map((row) => RequestModel.fromDb(row)).toList());
    }
    return requestDao
        .watchRequestsForProject(projectId)
        .map((rows) => rows.map((row) => RequestModel.fromDb(row)).toList());
  }

  @override
  Future<RepositoryResult<List<RequestEntity>>> getMyRequests({
    required String projectId,
    String? userId,
    bool forceRemote = false,
    int limit = 50,
    int offset = 0,
  }) async {
    // Get cached requests
    final rows = userId != null
        ? await requestDao.getRequestsForUser(projectId, userId)
        : await requestDao.getRequestsForProject(projectId);
    final cached = rows.map((row) => RequestModel.fromDb(row)).toList();

    // Get last sync timestamp
    final lastSyncKey = 'requests_last_synced_$projectId';
    final lastSyncStr = await metaDao.getValue(lastSyncKey);
    final lastSyncedAt = lastSyncStr != null ? int.tryParse(lastSyncStr) : null;

    // Check connectivity
    final isOnline = await networkInfo.isOnline();
    logger.d(
      'getMyRequests: online=$isOnline, forceRemote=$forceRemote, projectId=$projectId',
    );

    // If offline, return cached data
    if (!isOnline) {
      logger.i('Device offline, returning ${cached.length} cached requests');
      return RepositoryResult.local(
        cached,
        message: 'Offline mode. Showing cached data.',
        lastSyncedAt: lastSyncedAt,
      );
    }

    // Online - fetch from remote
    logger.i('Fetching requests from remote API for project $projectId');
    try {
      final filters = userId != null ? {'requester_id': userId} : null;
      final remoteData = await remoteDataSource.fetchProjectRequests(
        projectId,
        filters: filters,
        limit: limit,
        offset: offset,
      );
      logger.i(
        'Successfully fetched ${remoteData.length} requests from remote',
      );

      final nowMs = DateTime.now().millisecondsSinceEpoch;
      await db.transaction(() async {
        for (final data in remoteData) {
          // Ensure projectId is present
          if (data['project_id'] == null) {
            data['project_id'] = projectId;
          }
          final model = RequestModel.fromJson(data);
          await requestDao.insertRequest(model.toCompanion());
        }

        // Update last synced timestamp
        await metaDao.setValue(lastSyncKey, nowMs.toString());
      });

      // Return fresh remote data
      final updatedRows = userId != null
          ? await requestDao.getRequestsForUser(projectId, userId)
          : await requestDao.getRequestsForProject(projectId);
      final requests =
          updatedRows.map((row) => RequestModel.fromDb(row)).toList();
      logger.i('✅ Returned ${requests.length} requests from remote');
      return RepositoryResult.remote(requests, lastSyncedAt: nowMs);
    } on DioException catch (e) {
      logger.e('Dio error fetching remote requests: $e');
      // Network error - fallback to local
      return RepositoryResult.local(
        cached,
        message: 'Network error. Showing cached data.',
        lastSyncedAt: lastSyncedAt,
      );
    } catch (e) {
      logger.e('Error fetching remote requests: $e');
      return RepositoryResult.local(
        cached,
        message: 'Error loading data. Showing cached data.',
        lastSyncedAt: lastSyncedAt,
      );
    }
  }

  @override
  Future<void> createRequest(RequestEntity request) async {
    await db.transaction(() async {
      final model = RequestModel.fromEntity(request);
      await requestDao.insertRequest(model.toCompanion());

      await syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: const Uuid().v4(),
          projectId: request.projectId,
          entityType: 'request',
          entityId: request.id,
          action: 'create',
          payload: Value(jsonEncode(model.toJson())),
          status: const Value('PENDING'),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    });
  }

  @override
  Future<void> updateRequest(RequestEntity request) async {
    await db.transaction(() async {
      final model = RequestModel.fromEntity(request);
      await requestDao.updateRequest(model.toCompanion());

      await syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: const Uuid().v4(),
          projectId: request.projectId,
          entityType: 'request',
          entityId: request.id,
          action: 'update',
          payload: Value(jsonEncode(model.toJson())),
          status: const Value('PENDING'),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    });
  }

  @override
  Future<void> processSyncQueueItem(
    String projectId,
    String entityId,
    String action,
    String? payload,
  ) async {
    if (action == 'create') {
      if (payload == null) throw Exception('Payload missing for create');
      final map = jsonDecode(payload);
      final response = await remoteDataSource.createRequest(projectId, map);
      final serverId = response['id'];
      final serverUpdatedAt = response['updated_at'];

      if (serverId != null) {
        await requestDao.updateRequestServerFields(
          entityId,
          serverId,
          serverUpdatedAt is int
              ? serverUpdatedAt
              : DateTime.now().millisecondsSinceEpoch,
        );
      }
    } else if (action == 'update') {
      if (payload == null) throw Exception('Payload missing for update');
      final map = jsonDecode(payload);
      final request = await requestDao.getByLocalId(entityId);
      final serverId = request?.serverId;

      if (serverId != null) {
        await remoteDataSource.updateRequest(serverId, map);
      } else {
        throw Exception('Cannot update request without serverId');
      }
    }
  }
}

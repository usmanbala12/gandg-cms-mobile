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
          if (data['project_id'] == null && data['projectId'] == null) {
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
  Future<RequestEntity?> getRequestDetails(String requestId) async {
    try {
      final data = await remoteDataSource.fetchRequestDetails(requestId);
      if (data.isEmpty) return null;
      return RequestModel.fromJson(data);
    } catch (e) {
      logger.e('Error fetching request details: $e');
      // Try local cache
      final row = await requestDao.getByServerId(requestId);
      if (row != null) return RequestModel.fromDb(row);
      return null;
    }
  }

  @override
  Future<RepositoryResult<List<RequestEntity>>> getPendingApprovals({
    String? projectId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final remoteData = await remoteDataSource.fetchPendingApprovals(
        projectId: projectId,
        limit: limit,
        offset: offset,
      );
      
      final requests = remoteData
          .map((data) => RequestModel.fromJson(data))
          .toList();
      
      return RepositoryResult.remote(requests);
    } catch (e) {
      logger.e('Error fetching pending approvals: $e');
      return RepositoryResult.local([], message: 'Error loading pending approvals');
    }
  }

  @override
  Future<RequestEntity> createRequest(RequestEntity request) async {
    final model = RequestModel.fromEntity(request);
    final isOnline = await networkInfo.isOnline();

    if (isOnline) {
      // Try to create on backend first
      try {
        final response = await remoteDataSource.createRequest(
          request.projectId,
          model.toCreatePayload(isDraft: request.status == 'DRAFT'),
        );

        logger.i('Request created on backend: ${response['id']}');

        // Update local with server ID
        final serverModel = RequestModel.fromJson({
          ...response,
          'local_id': request.id,
          'project_id': request.projectId,
        });

        await requestDao.insertRequest(serverModel.toCompanion());
        return serverModel;
      } catch (e) {
        logger.e('Failed to create request on backend: $e');
        rethrow; // Propagate error so UI knows it failed
      }
    } else {
      // Offline: save locally and queue for sync
      logger.i('Offline: queuing request for sync');
      await db.transaction(() async {
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
      return request;
    }
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
  Future<void> deleteRequest(String requestId) async {
    await remoteDataSource.deleteRequest(requestId);
    // Try to delete from local DB by server ID
    final localRequest = await requestDao.getByServerId(requestId);
    if (localRequest != null) {
      await requestDao.deleteRequest(localRequest.id);
    }
  }

  // ========== WORKFLOW ACTIONS ==========

  @override
  Future<RequestEntity> submitRequest(String requestId) async {
    final data = await remoteDataSource.submitRequest(requestId);
    return RequestModel.fromJson(data);
  }

  @override
  Future<RequestEntity> approveRequest(
    String requestId, {
    String? comments,
  }) async {
    final data = await remoteDataSource.approveRequest(
      requestId,
      comments: comments,
    );
    return RequestModel.fromJson(data);
  }

  @override
  Future<RequestEntity> rejectRequest(
    String requestId, {
    required String reason,
    String? comments,
  }) async {
    final data = await remoteDataSource.rejectRequest(
      requestId,
      reason: reason,
      comments: comments,
    );
    return RequestModel.fromJson(data);
  }

  @override
  Future<RequestEntity> delegateApproval(
    String requestId, {
    required String toUserId,
    String? reason,
  }) async {
    final data = await remoteDataSource.delegateApproval(
      requestId,
      toUserId: toUserId,
      reason: reason,
    );
    return RequestModel.fromJson(data);
  }

  @override
  Future<RequestEntity> cancelRequest(
    String requestId, {
    String? reason,
  }) async {
    final data = await remoteDataSource.cancelRequest(requestId, reason: reason);
    return RequestModel.fromJson(data);
  }

  // ========== LINE ITEMS ==========

  @override
  Future<void> addLineItem(
    String requestId, {
    required String description,
    required int quantity,
    double? unitPrice,
    String? unit,
  }) async {
    await remoteDataSource.addLineItem(requestId, {
      'description': description,
      'quantity': quantity,
      if (unitPrice != null) 'unitPrice': unitPrice,
      if (unit != null) 'unit': unit,
    });
  }

  @override
  Future<void> deleteLineItem(String requestId, String itemId) async {
    await remoteDataSource.deleteLineItem(requestId, itemId);
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

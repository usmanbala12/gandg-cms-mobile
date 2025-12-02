import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/db/app_database.dart';
import '../../../../core/db/daos/media_dao.dart';
import '../../../../core/db/daos/meta_dao.dart';
import '../../../../core/db/daos/report_dao.dart';
import '../../../../core/db/daos/sync_queue_dao.dart';
import '../../../../core/db/repositories/report_repository.dart';
import '../../../../core/domain/repository_result.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/report_entity.dart';
import '../datasources/report_remote_datasource.dart';
import '../models/report_model.dart';

part '_create_report_method.dart';

class ReportRepositoryImpl implements ReportRepository {
  final AppDatabase db;
  final ReportDao reportDao;
  final MediaDao mediaDao;
  final MetaDao metaDao;
  final SyncQueueDao syncQueueDao;
  final ReportRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final Logger logger;

  ReportRepositoryImpl({
    required this.db,
    required this.reportDao,
    required this.mediaDao,
    required this.metaDao,
    required this.syncQueueDao,
    required this.remoteDataSource,
    required this.networkInfo,
    Logger? logger,
  }) : logger = logger ?? Logger();

  @override
  Stream<List<ReportEntity>> watchReports({String? projectId}) {
    return reportDao.watchReports(projectId: projectId).map((rows) {
      return rows.map((row) => ReportModel.fromDb(row)).toList();
    });
  }

  @override
  Future<RepositoryResult<List<ReportEntity>>> getReports({
    String? projectId,
    bool forceRemote = false,
  }) async {
    // Get cached reports
    final rows = await reportDao.getReports(projectId: projectId);
    final cached = rows.map((row) => ReportModel.fromDb(row)).toList();

    // Get last sync timestamp
    final lastSyncKey = projectId != null
        ? 'reports_last_synced_$projectId'
        : 'reports_last_synced';
    final lastSyncStr = await metaDao.getValue(lastSyncKey);
    final lastSyncedAt = lastSyncStr != null ? int.tryParse(lastSyncStr) : null;

    // Check connectivity
    final isOnline = await networkInfo.isOnline();
    logger.d(
      'getReports: online=$isOnline, forceRemote=$forceRemote, projectId=$projectId',
    );

    // If offline, return cached data
    if (!isOnline) {
      logger.i('Device offline, returning ${cached.length} cached reports');
      return RepositoryResult.local(
        cached,
        message: 'Offline mode. Showing cached data.',
        lastSyncedAt: lastSyncedAt,
      );
    }

    // If projectId is null, can't fetch remote
    if (projectId == null) {
      logger.w('No projectId provided, returning cached reports');
      return RepositoryResult.local(
        cached,
        message: 'No project selected.',
        lastSyncedAt: lastSyncedAt,
      );
    }

    // Online - fetch from remote
    logger.i('Fetching reports from remote API for project $projectId');
    try {
      final remoteData = await remoteDataSource.fetchProjectReports(projectId);
      logger.i('Successfully fetched ${remoteData.length} reports from remote');

      final nowMs = DateTime.now().millisecondsSinceEpoch;
      await db.transaction(() async {
        for (final data in remoteData) {
          final model = ReportModel.fromJson(data);
          await reportDao.insertReport(model.toCompanion());
        }

        // Update last synced timestamp
        await metaDao.setValue(lastSyncKey, nowMs.toString());
      });

      // Return fresh remote data
      final updatedRows = await reportDao.getReports(projectId: projectId);
      final reports = updatedRows
          .map((row) => ReportModel.fromDb(row))
          .toList();
      logger.i('✅ Returned ${reports.length} reports from remote');
      return RepositoryResult.remote(reports, lastSyncedAt: nowMs);
    } on DioException catch (e) {
      logger.e('Dio error fetching remote reports: $e');

      // Handle auth errors
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        logger.e('Authentication error fetching reports');
        // For now, fallback to local (could throw auth exception instead)
      }

      // Network error - fallback to local
      logger.w('Network error fetching reports, falling back to cached data');
      return RepositoryResult.local(
        cached,
        message: 'Network error. Showing cached data.',
        lastSyncedAt: lastSyncedAt,
      );
    } on SocketException catch (e) {
      logger.e('Socket error fetching remote reports: $e');
      return RepositoryResult.local(
        cached,
        message: 'Connection error. Showing cached data.',
        lastSyncedAt: lastSyncedAt,
      );
    } catch (e) {
      logger.e('Error fetching remote reports: $e');
      // Fallback to local
      return RepositoryResult.local(
        cached,
        message: 'Error loading data. Showing cached data.',
        lastSyncedAt: lastSyncedAt,
      );
    }
  }

  @override
  Future<void> createReport(ReportEntity report) async {
    await db.transaction(() async {
      final model = ReportModel.fromEntity(report);
      await reportDao.insertReport(model.toCompanion());

      await syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: const Uuid().v4(),
          projectId: report.projectId,
          entityType: 'report',
          entityId: report.id,
          action: 'create',
          payload: Value(jsonEncode(model.toJson())),
          status: const Value('PENDING'),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    });
  }

  @override
  Future<void> updateReport(ReportEntity report) async {
    await db.transaction(() async {
      final model = ReportModel.fromEntity(report);
      await reportDao.updateReport(model.toCompanion());

      await syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: const Uuid().v4(),
          projectId: report.projectId,
          entityType: 'report',
          entityId: report.id,
          action: 'update',
          payload: Value(jsonEncode(model.toJson())),
          status: const Value('PENDING'),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    });
  }

  @override
  Future<void> saveDraft(ReportEntity report) async {
    final model = ReportModel.fromEntity(report.copyWith(status: 'DRAFT'));
    await reportDao.insertReport(model.toCompanion());
  }

  @override
  Future<void> deleteReport(String id) async {
    // Check if allowed offline or if needs to be online
    // For now, assume we mark deleted and sync
    final report = await reportDao.getReportById(id);
    if (report == null) return;

    await db.transaction(() async {
      await reportDao.deleteReport(id);
      await syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: const Uuid().v4(),
          projectId: report.projectId,
          entityType: 'report',
          entityId: id,
          action: 'delete',
          status: const Value('PENDING'),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    });
  }

  @override
  Future<void> attachMedia(String localPath, String reportLocalId) async {
    final report = await reportDao.getReportById(reportLocalId);
    if (report == null) throw Exception('Report not found');

    final file = File(localPath);
    if (!await file.exists()) throw Exception('File not found');

    final mediaId = const Uuid().v4();
    final size = await file.length();
    final mime = 'application/octet-stream'; // TODO: detect mime

    // Generate thumbnail (placeholder for now)
    final thumbnailPath = localPath; // In real app, generate actual thumb

    await db.transaction(() async {
      await mediaDao.insertMedia(
        MediaFilesCompanion.insert(
          id: mediaId,
          localPath: localPath,
          projectId: report.projectId,
          parentType: 'report',
          parentId: reportLocalId,
          uploadStatus: const Value('PENDING'),
          size: size,
          mime: Value(mime),
          thumbnailPath: Value(thumbnailPath),
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      // Update report media_ids
      List<String> currentMediaIds = [];
      if (report.mediaIds != null) {
        currentMediaIds = List<String>.from(jsonDecode(report.mediaIds!));
      }
      currentMediaIds.add(mediaId);

      await reportDao.updateReportMedia(reportLocalId, currentMediaIds);

      // Enqueue media upload
      await syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: const Uuid().v4(),
          projectId: report.projectId,
          entityType: 'media',
          entityId: mediaId,
          action: 'upload',
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
      // Check if media needs to be uploaded first?
      // For now, assume media is handled separately via media queue items
      // But we might need to wait for server_ids of media?
      // Backend contract usually allows local IDs or requires separate media upload first.
      // Assuming we send the payload as is.

      final response = await remoteDataSource.createReport(projectId, map);
      final serverId = response['id'];
      final serverUpdatedAt = response['updated_at']; // or similar

      if (serverId != null) {
        await reportDao.updateReportServerFields(
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
      final report = await reportDao.getReportById(entityId);
      final serverId = report?.serverId;

      if (serverId != null) {
        await remoteDataSource.updateReport(projectId, serverId, map);
      } else {
        // If no serverId, maybe it was created offline and not synced yet?
        // Should have been handled by create action.
        throw Exception('Cannot update report without serverId');
      }
    } else if (action == 'delete') {
      final report = await reportDao.getReportById(entityId);
      final serverId = report?.serverId;
      if (serverId != null) {
        await remoteDataSource.deleteReport(projectId, serverId);
      }
    }
  }

  @override
  Future<void> cleanupOldReports(String projectId) async {
    // Delete reports older than 30 days
    final cutoff = DateTime.now()
        .subtract(const Duration(days: 30))
        .millisecondsSinceEpoch;

    // This is a simplified cleanup. In reality we'd query for IDs and delete.
    // Drift doesn't support complex delete-where easily without custom queries.
    // For now, we'll leave this as a TODO or implement a custom query.
    await db.customStatement(
      'DELETE FROM reports WHERE project_id = ? AND created_at < ?',
      [projectId, cutoff],
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getTemplates({
    bool forceRefresh = false,
  }) async {
    try {
      return await remoteDataSource.fetchTemplates();
    } catch (e) {
      logger.e('Error fetching templates: $e');
      return [];
    }
  }

  @override
  Future<String> createReportWithData({
    required String projectId,
    required String templateId,
    required Map<String, dynamic> submissionData,
  }) async {
    final reportId = const Uuid().v4();
    final now = DateTime.now().millisecondsSinceEpoch;

    print('📝 Creating report: $reportId');
    print('   Project: $projectId');
    print('   Template: $templateId');

    // Create report entity
    final report = ReportEntity(
      id: reportId,
      projectId: projectId,
      formTemplateId: templateId,
      reportDate: now,
      submissionData: submissionData,
      status: 'PENDING',
      createdAt: now,
      updatedAt: now,
    );

    // Atomic transaction: insert report + enqueue sync
    await db.transaction(() async {
      // Insert report
      await reportDao.insertReport(
        ReportsCompanion.insert(
          id: report.id,
          projectId: report.projectId,
          reportDate: report.reportDate,
          status: Value(report.status),
          createdAt: report.createdAt,
          updatedAt: report.updatedAt,
          formTemplateId: Value(report.formTemplateId),
          submissionData: Value(jsonEncode(report.submissionData)),
          mediaIds: const Value('[]'),
        ),
      );

      // Enqueue sync item
      await syncQueueDao.enqueue(
        SyncQueueCompanion.insert(
          id: const Uuid().v4(),
          projectId: projectId,
          entityType: 'report',
          entityId: reportId,
          action: 'create',
          createdAt: now,
          payload: Value(
            jsonEncode({
              'form_template_id': templateId,
              'submission_data': submissionData,
              'report_date': now,
            }),
          ),
        ),
      );
    });

    logger.i('✅ Report created and enqueued: $reportId');
    return reportId;
  }
}

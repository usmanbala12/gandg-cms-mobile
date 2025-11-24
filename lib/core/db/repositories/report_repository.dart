import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:logger/logger.dart';

import '../app_database.dart';
import '../daos/report_dao.dart';
import '../daos/sync_queue_dao.dart';
import '../db_utils.dart';
import '../../network/api_client.dart';

/// Repository for report operations with atomic insert + enqueue.
class ReportRepository {
  final AppDatabase db;
  final ReportDao reportDao;
  final SyncQueueDao syncQueueDao;
  final ApiClient apiClient;
  final Logger logger;

  ReportRepository({
    required this.db,
    required this.reportDao,
    required this.syncQueueDao,
    required this.apiClient,
    Logger? logger,
  }) : logger = logger ?? Logger();

  /// Create a report locally and enqueue for sync.
  /// Atomically inserts the report and enqueues a sync item in a single transaction.
  Future<String> createReportLocallyAndEnqueue(
    String projectId,
    Map<String, dynamic> reportData,
  ) async {
    try {
      final reportId = uuid();
      final nowMs = now();

      await db.transaction(() async {
        // Insert report
        await reportDao.insertReport(
          ReportsCompanion.insert(
            id: reportId,
            projectId: projectId,
            formTemplateId: Value(reportData['formTemplateId']),
            reportDate: reportData['reportDate'] as int? ?? nowMs,
            submissionData: reportData['submissionData'] != null
                ? Value(jsonEncode(reportData['submissionData']))
                : const Value(null),
            location: reportData['location'] != null
                ? Value(jsonEncode(reportData['location']))
                : const Value(null),
            mediaIds: reportData['mediaIds'] != null
                ? Value(jsonEncode(reportData['mediaIds']))
                : const Value(null),
            status: const Value(ReportStatus.draft),
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );

        // Enqueue sync item
        await syncQueueDao.enqueue(
          SyncQueueCompanion.insert(
            id: uuid(),
            projectId: projectId,
            entityType: 'report',
            entityId: reportId,
            action: SyncQueueAction.create,
            payload: Value(jsonEncode(reportData)),
            priority: const Value(1),
            status: const Value(SyncQueueStatus.pending),
            attempts: const Value(0),
            lastAttemptAt: const Value(null),
            errorMessage: const Value(null),
            createdAt: nowMs,
          ),
        );
      });

      logger.i('Created report $reportId in project $projectId and enqueued');
      return reportId;
    } catch (e) {
      logger.e('Error creating report in project $projectId: $e');
      rethrow;
    }
  }

  /// Update a report locally and enqueue for sync.
  Future<void> updateReportLocallyAndEnqueue(
    String projectId,
    String reportId,
    Map<String, dynamic> reportData,
  ) async {
    try {
      final nowMs = now();

      await db.transaction(() async {
        // Update report
        await reportDao.updateReport(
          ReportsCompanion(
            id: Value(reportId),
            projectId: Value(projectId),
            formTemplateId: reportData['formTemplateId'] != null
                ? Value(reportData['formTemplateId'])
                : const Value.absent(),
            reportDate: reportData['reportDate'] != null
                ? Value(reportData['reportDate'])
                : const Value.absent(),
            submissionData: reportData['submissionData'] != null
                ? Value(jsonEncode(reportData['submissionData']))
                : const Value.absent(),
            location: reportData['location'] != null
                ? Value(jsonEncode(reportData['location']))
                : const Value.absent(),
            mediaIds: reportData['mediaIds'] != null
                ? Value(jsonEncode(reportData['mediaIds']))
                : const Value.absent(),
            updatedAt: Value(nowMs),
          ),
        );

        // Enqueue sync item
        await syncQueueDao.enqueue(
          SyncQueueCompanion.insert(
            id: uuid(),
            projectId: projectId,
            entityType: 'report',
            entityId: reportId,
            action: SyncQueueAction.update,
            payload: Value(jsonEncode(reportData)),
            priority: const Value(1),
            status: const Value(SyncQueueStatus.pending),
            attempts: const Value(0),
            lastAttemptAt: const Value(null),
            errorMessage: const Value(null),
            createdAt: nowMs,
          ),
        );
      });

      logger.i('Updated report $reportId in project $projectId and enqueued');
    } catch (e) {
      logger.e('Error updating report $reportId in project $projectId: $e');
      rethrow;
    }
  }

  /// Delete a report locally and enqueue for sync.
  Future<void> deleteReportLocallyAndEnqueue(
    String projectId,
    String reportId,
  ) async {
    try {
      final nowMs = now();

      await db.transaction(() async {
        // Mark report as deleted (soft delete)
        await reportDao.updateReport(
          ReportsCompanion(
            id: Value(reportId),
            status: const Value(ReportStatus.error),
            updatedAt: Value(nowMs),
          ),
        );

        // Enqueue sync item
        await syncQueueDao.enqueue(
          SyncQueueCompanion.insert(
            id: uuid(),
            projectId: projectId,
            entityType: 'report',
            entityId: reportId,
            action: SyncQueueAction.delete,
            payload: const Value(null),
            priority: const Value(1),
            status: const Value(SyncQueueStatus.pending),
            attempts: const Value(0),
            lastAttemptAt: const Value(null),
            errorMessage: const Value(null),
            createdAt: nowMs,
          ),
        );
      });

      logger.i('Deleted report $reportId in project $projectId and enqueued');
    } catch (e) {
      logger.e('Error deleting report $reportId in project $projectId: $e');
      rethrow;
    }
  }

  /// Process a sync queue item for a report.
  /// Routes to the appropriate API endpoint based on action.
  Future<void> processSyncQueueItem(
    String projectId,
    String reportId,
    String action,
    String? payload,
  ) async {
    try {
      final payloadMap = payload != null ? jsonDecode(payload) : {};

      switch (action) {
        case SyncQueueAction.create:
          final response = await apiClient.createReport(projectId, payloadMap);
          final serverId = response['id'] ?? response['serverId'];
          final serverUpdatedAt = response['updatedAt'] ?? now();
          if (serverId != null) {
            await reportDao.updateReportServerFields(
              reportId,
              serverId,
              serverUpdatedAt,
            );
          }
          break;

        case SyncQueueAction.update:
          final response = await apiClient.updateReport(
            projectId,
            reportId,
            payloadMap,
          );
          final serverUpdatedAt = response['updatedAt'] ?? now();
          await reportDao.updateReport(
            ReportsCompanion(
              id: Value(reportId),
              serverUpdatedAt: Value(serverUpdatedAt),
              updatedAt: Value(now()),
            ),
          );
          break;

        case SyncQueueAction.delete:
          await apiClient.deleteReport(projectId, reportId);
          await reportDao.deleteReport(reportId);
          break;

        default:
          logger.w('Unknown action for report: $action');
      }

      logger.i('Processed sync queue item for report $reportId: $action');
    } catch (e) {
      logger.e('Error processing sync queue item for report $reportId: $e');
      rethrow;
    }
  }

  /// Get reports for a project with pagination.
  Future<List<Map<String, dynamic>>> getReportsForProject(
    String projectId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final reports = await reportDao.getReportsForProject(
        projectId,
        limit: limit,
        offset: offset,
      );
      return reports
          .map(
            (r) => {
              'id': r.id,
              'projectId': r.projectId,
              'formTemplateId': r.formTemplateId,
              'reportDate': r.reportDate,
              'submissionData': r.submissionData,
              'location': r.location,
              'mediaIds': r.mediaIds,
              'status': r.status,
              'createdAt': r.createdAt,
              'updatedAt': r.updatedAt,
              'serverId': r.serverId,
              'serverUpdatedAt': r.serverUpdatedAt,
            },
          )
          .toList();
    } catch (e) {
      logger.e('Error fetching reports for project $projectId: $e');
      rethrow;
    }
  }

  /// Watch reports for a project (stream).
  Stream<List<Map<String, dynamic>>> watchReportsForProject(String projectId) {
    return reportDao
        .watchReportsForProject(projectId)
        .map(
          (reports) => reports
              .map(
                (r) => {
                  'id': r.id,
                  'projectId': r.projectId,
                  'formTemplateId': r.formTemplateId,
                  'reportDate': r.reportDate,
                  'submissionData': r.submissionData,
                  'location': r.location,
                  'mediaIds': r.mediaIds,
                  'status': r.status,
                  'createdAt': r.createdAt,
                  'updatedAt': r.updatedAt,
                  'serverId': r.serverId,
                  'serverUpdatedAt': r.serverUpdatedAt,
                },
              )
              .toList(),
        );
  }
}

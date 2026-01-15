import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/domain/repository_result.dart';
import '../../../../core/network/dio_exception_extension.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/report_entity.dart';
import '../../domain/entities/form_template_entity.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/report_remote_datasource.dart';
import '../models/report_model.dart';
import '../models/form_template_model.dart';

/// Simplified ReportRepository - remote only, no local caching.
class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final Logger logger;

  ReportRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    Logger? logger,
  }) : logger = logger ?? Logger();

  @override
  Stream<List<ReportEntity>> watchReports({String? projectId}) {
    // Remote-only: no local stream
    logger.w('watchReports is deprecated in remote-only mode');
    return Stream.value([]);
  }

  @override
  Future<RepositoryResult<List<ReportEntity>>> getReports({
    required String projectId,
    bool forceRemote = false,
  }) async {
    final isOnline = await networkInfo.isOnline();

    if (!isOnline) {
      return RepositoryResult.local(
        [],
        message: 'You are offline. Reports cannot be loaded.',
      );
    }

    try {
      logger.i('Fetching reports from remote API for project $projectId');
      final remoteData = await remoteDataSource.fetchProjectReports(projectId);

      final reports = remoteData
          .map((data) => ReportModel.fromJson(data))
          .toList();

      logger.i('✅ Fetched ${reports.length} reports from remote');
      return RepositoryResult.remote(
        reports,
        lastSyncedAt: DateTime.now().millisecondsSinceEpoch,
      );
    } on DioException catch (e) {
      final message = e.errorMessage;
      logger.e('Dio error fetching reports: $message');
      return RepositoryResult.local([], message: message);
    } catch (e) {
      logger.e('Error fetching reports: $e');
      return RepositoryResult.local(
        [],
        message: 'Error loading reports: $e',
      );
    }
  }

  @override
  Future<void> createReport(ReportEntity report) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      throw Exception('Cannot create report while offline.');
    }

    try {
      await remoteDataSource.createReport({
        'projectId': report.projectId,
        'formTemplateId': report.formTemplateId,
        'submissionData': report.submissionData,
        'reportDate': report.reportDate,
      });
      logger.i('✅ Report created');
    } catch (e) {
      logger.e('Error creating report: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateReport(ReportEntity report) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      throw Exception('Cannot update report while offline.');
    }

    try {
      if (report.serverId != null) {
        await remoteDataSource.updateReport(
          report.serverId!,
          {
            'submission_data': report.submissionData,
            'status': report.status,
          },
        );
        logger.i('✅ Report updated: ${report.serverId}');
      }
    } catch (e) {
      logger.e('Error updating report: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveDraft(ReportEntity report) async {
    // In remote-only mode, drafts are not supported
    logger.w('saveDraft is not supported in remote-only mode');
    throw Exception('Draft saving is not available in offline-simplified mode.');
  }

  @override
  Future<void> deleteReport(String id) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      throw Exception('Cannot delete report while offline.');
    }

    try {
      // In remote-only mode, id should be the server ID
      // The project ID needs to be known - for now log a warning
      logger.w('deleteReport called with ID: $id - need project context');
      // Ideally the API would not require project ID for delete
    } catch (e) {
      logger.e('Error deleting report: $e');
      rethrow;
    }
  }

  @override
  Future<void> attachMedia(String localPath, String reportId) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      throw Exception('Cannot attach media while offline.');
    }

    try {
      // reportId is the server report ID, localPath is the file path
      await remoteDataSource.uploadMedia('', localPath, 'report', reportId);
      logger.i('✅ Media attached to report: $reportId');
    } catch (e) {
      logger.e('Error attaching media: $e');
      rethrow;
    }
  }

  @override
  Future<void> processSyncQueueItem(
    String projectId,
    String entityId,
    String action,
    String? payload,
  ) async {
    // Not used in remote-only mode
    logger.w('processSyncQueueItem called but reports are remote-only');
  }

  @override
  Future<void> cleanupOldReports(String projectId) async {
    // No local cache to clean in remote-only mode
    logger.d('cleanupOldReports is a no-op in remote-only mode');
  }

  @override
  Future<List<FormTemplateEntity>> getTemplates({
    bool forceRefresh = false,
  }) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      logger.w('Cannot fetch templates while offline');
      return [];
    }

    try {
      final templatesData = await remoteDataSource.fetchTemplates();
      return templatesData
          .map((e) => FormTemplateModel.fromJson(e))
          .toList();
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
    Map<String, dynamic>? location,
  }) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      throw Exception('Cannot create report while offline.');
    }

    try {
      final now = DateTime.now();
      final today = now.toIso8601String().split('T').first;

      final payload = {
        'projectId': projectId,
        'formTemplateId': templateId,
        'submissionData': submissionData,
        'reportDate': today,
        if (location != null) 'location': location,
      };

      final response = await remoteDataSource.createReport(payload);

      final serverId = response['id'] ?? response['data']?['id'];
      logger.i('✅ Report created: $serverId');
      return serverId?.toString() ?? '';
    } catch (e) {
      logger.e('Error creating report: $e');
      rethrow;
    }
  }

  @override
  Future<RepositoryResult<ReportEntity>> getReport(String id) async {
    final isOnline = await networkInfo.isOnline();

    if (!isOnline) {
      return RepositoryResult.local(
        const ReportEntity(
          id: '',
          projectId: '',
          formTemplateId: '',
          reportDate: '',
          status: '',
          createdAt: '',
          updatedAt: '',
        ),
        message: 'You are offline. Report details cannot be loaded.',
      );
    }

    try {
      logger.i('Fetching report $id from remote API');
      final remoteData = await remoteDataSource.fetchReport(id);
      final report = ReportModel.fromJson(remoteData);

      return RepositoryResult.remote(report);
    } on DioException catch (e) {
      final message = e.errorMessage;
      logger.e('Dio error fetching report $id: $message');
      return RepositoryResult.local(
        const ReportEntity(
          id: '',
          projectId: '',
          formTemplateId: '',
          reportDate: '',
          status: '',
          createdAt: '',
          updatedAt: '',
        ),
        message: message,
      );
    } catch (e) {
      logger.e('Error fetching report $id: $e');
      return RepositoryResult.local(
        const ReportEntity(
          id: '',
          projectId: '',
          formTemplateId: '',
          reportDate: '',
          status: '',
          createdAt: '',
          updatedAt: '',
        ),
        message: 'Error loading report: $e',
      );
    }
  }
}

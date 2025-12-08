import '../../../core/domain/repository_result.dart';
import '../../../features/reports/domain/entities/report_entity.dart';

abstract class ReportRepository {
  Stream<List<ReportEntity>> watchReports({String? projectId});
  Future<RepositoryResult<List<ReportEntity>>> getReports({
    required String projectId,
    bool forceRemote = false,
  });
  Future<void> createReport(ReportEntity report);
  Future<void> updateReport(ReportEntity report);
  Future<void> saveDraft(ReportEntity report);
  Future<void> deleteReport(String id);
  Future<void> attachMedia(String localPath, String reportLocalId);
  Future<void> processSyncQueueItem(
    String projectId,
    String entityId,
    String action,
    String? payload,
  );
  Future<void> cleanupOldReports(String projectId);
  Future<List<Map<String, dynamic>>> getTemplates({bool forceRefresh = false});

  /// Creates a report with the given data and returns the report ID
  Future<String> createReportWithData({
    required String projectId,
    required String templateId,
    required Map<String, dynamic> submissionData,
  });
}

import '../../../features/reports/domain/entities/report_entity.dart';

abstract class ReportRepository {
  Stream<List<ReportEntity>> watchReports({String? projectId});
  Future<List<ReportEntity>> getReports({
    String? projectId,
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
  Future<List<Map<String, dynamic>>> getTemplates();
}

import '../../../../core/network/api_client.dart';

class ReportRemoteDataSource {
  final ApiClient apiClient;

  ReportRemoteDataSource(this.apiClient);

  Future<List<Map<String, dynamic>>> fetchTemplates() async {
    return await apiClient.fetchTemplates();
  }

  Future<List<Map<String, dynamic>>> fetchProjectReports(
    String projectId, {
    int page = 0,
    int size = 10,
  }) async {
    return await apiClient.fetchProjectReports(
      projectId,
      page: page,
      size: size,
    );
  }

  Future<Map<String, dynamic>> fetchReport(
    String reportId,
  ) async {
    return await apiClient.fetchReport(reportId);
  }

  Future<Map<String, dynamic>> createReport(
    Map<String, dynamic> payload,
  ) async {
    return await apiClient.createReport(payload);
  }

  Future<Map<String, dynamic>> updateReport(
    String reportId,
    Map<String, dynamic> payload,
  ) async {
    return await apiClient.updateReport(reportId, payload);
  }

  Future<void> deleteReport(String projectId, String reportId) async {
    await apiClient.deleteReport(projectId, reportId);
  }

  Future<Map<String, dynamic>> uploadMedia(
    String projectId,
    String filePath,
    String parentType,
    String parentId, {
    String? mimeType,
  }) async {
    return await apiClient.uploadMedia(
      projectId,
      filePath,
      parentType,
      parentId,
      mimeType: mimeType,
    );
  }
}

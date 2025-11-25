import '../../../../core/network/api_client.dart';

class ReportRemoteDataSource {
  final ApiClient apiClient;

  ReportRemoteDataSource(this.apiClient);

  Future<List<Map<String, dynamic>>> fetchTemplates() async {
    return await apiClient.fetchTemplates();
  }

  Future<List<Map<String, dynamic>>> fetchProjectReports(
    String projectId, {
    int limit = 50,
    int offset = 0,
  }) async {
    return await apiClient.fetchProjectReports(
      projectId,
      limit: limit,
      offset: offset,
    );
  }

  Future<Map<String, dynamic>> fetchReport(
    String projectId,
    String reportId,
  ) async {
    return await apiClient.fetchReport(projectId, reportId);
  }

  Future<Map<String, dynamic>> createReport(
    String projectId,
    Map<String, dynamic> payload,
  ) async {
    return await apiClient.createReport(projectId, payload);
  }

  Future<Map<String, dynamic>> updateReport(
    String projectId,
    String reportId,
    Map<String, dynamic> payload,
  ) async {
    return await apiClient.updateReport(projectId, reportId, payload);
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

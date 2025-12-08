import '../../../../core/network/api_client.dart';

class RequestRemoteDataSource {
  final ApiClient apiClient;

  RequestRemoteDataSource(this.apiClient);

  Future<List<Map<String, dynamic>>> fetchProjectRequests(
    String projectId, {
    Map<String, dynamic>? filters,
    int limit = 50,
    int offset = 0,
  }) async {
    return await apiClient.fetchProjectRequests(
      projectId,
      filters: filters,
      limit: limit,
      offset: offset,
    );
  }

  Future<Map<String, dynamic>> createRequest(
    String projectId,
    Map<String, dynamic> payload,
  ) async {
    return await apiClient.createRequest(projectId, payload);
  }

  Future<Map<String, dynamic>> fetchRequestDetails(String requestId) async {
    return await apiClient.fetchRequestDetails(requestId);
  }

  Future<Map<String, dynamic>> updateRequest(
    String requestId,
    Map<String, dynamic> payload,
  ) async {
    return await apiClient.updateRequest(requestId, payload);
  }
}

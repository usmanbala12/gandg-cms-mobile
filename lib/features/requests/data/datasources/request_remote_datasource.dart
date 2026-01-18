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

  Future<void> deleteRequest(String requestId) async {
    await apiClient.deleteRequest(requestId);
  }

  // ========== WORKFLOW ACTIONS ==========

  Future<Map<String, dynamic>> submitRequest(String requestId) async {
    return await apiClient.submitRequest(requestId);
  }

  Future<Map<String, dynamic>> approveRequest(
    String requestId, {
    String? comments,
  }) async {
    return await apiClient.approveRequest(requestId, comments: comments);
  }

  Future<Map<String, dynamic>> rejectRequest(
    String requestId, {
    required String reason,
    String? comments,
  }) async {
    return await apiClient.rejectRequest(
      requestId,
      reason: reason,
      comments: comments,
    );
  }

  Future<Map<String, dynamic>> delegateApproval(
    String requestId, {
    required String toUserId,
    String? reason,
  }) async {
    return await apiClient.delegateApproval(
      requestId,
      toUserId: toUserId,
      reason: reason,
    );
  }

  Future<Map<String, dynamic>> cancelRequest(
    String requestId, {
    String? reason,
  }) async {
    return await apiClient.cancelRequest(requestId, reason: reason);
  }

  Future<List<Map<String, dynamic>>> fetchPendingApprovals({
    String? projectId,
    int page = 0,
    int size = 50,
  }) async {
    return await apiClient.fetchPendingApprovals(
      projectId: projectId,
      page: page,
      size: size,
    );
  }

  // ========== LINE ITEMS ==========

  Future<Map<String, dynamic>> addLineItem(
    String requestId,
    Map<String, dynamic> payload,
  ) async {
    return await apiClient.addRequestLineItem(requestId, payload);
  }

  Future<void> deleteLineItem(String requestId, String itemId) async {
    await apiClient.deleteRequestLineItem(requestId, itemId);
  }
}

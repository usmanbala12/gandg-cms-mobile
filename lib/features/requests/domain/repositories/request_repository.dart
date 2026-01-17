import '../../../../core/domain/repository_result.dart';
import '../entities/request_entity.dart';

abstract class RequestRepository {
  /// Watch requests for a project (reactive stream)
  Stream<List<RequestEntity>> watchMyRequests({
    required String projectId,
    String? userId,
  });

  /// Get requests with remote-first strategy
  Future<RepositoryResult<List<RequestEntity>>> getMyRequests({
    required String projectId,
    String? userId,
    bool forceRemote = false,
    int limit = 50,
    int offset = 0,
  });

  /// Get request details by ID
  Future<RequestEntity?> getRequestDetails(String requestId);

  /// Get pending approvals for current user
  Future<RepositoryResult<List<RequestEntity>>> getPendingApprovals({
    String? projectId,
    int limit = 50,
    int offset = 0,
  });

  /// Create a new request
  Future<RequestEntity> createRequest(RequestEntity request);

  /// Update an existing request
  Future<void> updateRequest(RequestEntity request);

  /// Delete a request
  Future<void> deleteRequest(String requestId);

  // ========== WORKFLOW ACTIONS ==========

  /// Submit a draft request for approval
  Future<RequestEntity> submitRequest(String requestId);

  /// Approve a pending request
  Future<RequestEntity> approveRequest(String requestId, {String? comments});

  /// Reject a pending request
  Future<RequestEntity> rejectRequest(
    String requestId, {
    required String reason,
    String? comments,
  });

  /// Delegate approval to another user
  Future<RequestEntity> delegateApproval(
    String requestId, {
    required String toUserId,
    String? reason,
  });

  /// Cancel an active request
  Future<RequestEntity> cancelRequest(String requestId, {String? reason});

  // ========== LINE ITEMS ==========

  /// Add a line item to a request
  Future<void> addLineItem(
    String requestId, {
    required String description,
    required int quantity,
    double? unitPrice,
    String? unit,
  });

  /// Delete a line item from a request
  Future<void> deleteLineItem(String requestId, String itemId);

  /// Process a sync queue item for requests
  Future<void> processSyncQueueItem(
    String projectId,
    String entityId,
    String action,
    String? payload,
  );
}

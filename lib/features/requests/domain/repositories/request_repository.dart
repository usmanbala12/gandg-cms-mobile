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

  /// Create a new request
  Future<void> createRequest(RequestEntity request);

  /// Update an existing request
  Future<void> updateRequest(RequestEntity request);

  /// Process a sync queue item for requests
  Future<void> processSyncQueueItem(
    String projectId,
    String entityId,
    String action,
    String? payload,
  );
}

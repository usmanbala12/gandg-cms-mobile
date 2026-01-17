import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/domain/repository_result.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/request_entity.dart';
import '../../domain/repositories/request_repository.dart';
import '../datasources/request_remote_datasource.dart';
import '../models/request_model.dart';

class RequestRepositoryImpl implements RequestRepository {
  final RequestRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final Logger logger;

  RequestRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    Logger? logger,
  }) : logger = logger ?? Logger();

  @override
  Future<RepositoryResult<List<RequestEntity>>> getMyRequests({
    required String projectId,
    String? userId,
    bool forceRemote = false,
    int limit = 50,
    int offset = 0,
  }) async {
    // Check connectivity
    final isOnline = await networkInfo.isOnline();
    logger.d(
      'getMyRequests: online=$isOnline, forceRemote=$forceRemote, projectId=$projectId',
    );

    if (!isOnline) {
      return RepositoryResult.local(
        [],
        message: 'Offline mode. Connect to the internet to view requests.',
      );
    }

    try {
      final filters = userId != null ? {'requester_id': userId} : null;
      final remoteData = await remoteDataSource.fetchProjectRequests(
        projectId,
        filters: filters,
        limit: limit,
        offset: offset,
      );
      
      final requests = remoteData.map((data) => RequestModel.fromJson(data)).toList();
      return RepositoryResult.remote(requests);
    } on DioException catch (e) {
      logger.e('Dio error fetching remote requests: $e');
      return RepositoryResult.error([], 'Network error while fetching requests.');
    } catch (e) {
      logger.e('Error fetching remote requests: $e');
      return RepositoryResult.error([], 'Error loading requests.');
    }
  }

  @override
  Future<RequestEntity?> getRequestDetails(String requestId) async {
    try {
      final data = await remoteDataSource.fetchRequestDetails(requestId);
      if (data.isEmpty) return null;
      return RequestModel.fromJson(data);
    } catch (e) {
      logger.e('Error fetching request details: $e');
      return null;
    }
  }

  @override
  Future<RepositoryResult<List<RequestEntity>>> getPendingApprovals({
    String? projectId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final remoteData = await remoteDataSource.fetchPendingApprovals(
        projectId: projectId,
        limit: limit,
        offset: offset,
      );
      
      final requests = remoteData
          .map((data) => RequestModel.fromJson(data))
          .toList();
      
      return RepositoryResult.remote(requests);
    } catch (e) {
      logger.e('Error fetching pending approvals: $e');
      return RepositoryResult.error([], 'Error loading pending approvals');
    }
  }

  @override
  Future<RequestEntity> createRequest(RequestEntity request) async {
    final model = RequestModel.fromEntity(request);
    final isOnline = await networkInfo.isOnline();

    if (!isOnline) {
      throw Exception('Internet connection required to create a request.');
    }

    try {
      final response = await remoteDataSource.createRequest(
        request.projectId,
        model.toCreatePayload(isDraft: request.status == 'DRAFT'),
      );

      return RequestModel.fromJson({
        ...response,
        'local_id': request.id,
        'project_id': request.projectId,
      });
    } catch (e) {
      logger.e('Failed to create request on backend: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateRequest(RequestEntity request) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      throw Exception('Internet connection required to update a request.');
    }

    if (request.serverId == null) {
      throw Exception('Cannot update a request without a server ID.');
    }

    final model = RequestModel.fromEntity(request);
    await remoteDataSource.updateRequest(request.serverId!, model.toJson());
  }

  @override
  Future<void> deleteRequest(String requestId) async {
    final isOnline = await networkInfo.isOnline();
    if (!isOnline) {
      throw Exception('Internet connection required to delete a request.');
    }
    await remoteDataSource.deleteRequest(requestId);
  }

  // ========== WORKFLOW ACTIONS ==========

  @override
  Future<RequestEntity> submitRequest(String requestId) async {
    final data = await remoteDataSource.submitRequest(requestId);
    return RequestModel.fromJson(data);
  }

  @override
  Future<RequestEntity> approveRequest(
    String requestId, {
    String? comments,
  }) async {
    final data = await remoteDataSource.approveRequest(
      requestId,
      comments: comments,
    );
    return RequestModel.fromJson(data);
  }

  @override
  Future<RequestEntity> rejectRequest(
    String requestId, {
    required String reason,
    String? comments,
  }) async {
    final data = await remoteDataSource.rejectRequest(
      requestId,
      reason: reason,
      comments: comments,
    );
    return RequestModel.fromJson(data);
  }

  @override
  Future<RequestEntity> delegateApproval(
    String requestId, {
    required String toUserId,
    String? reason,
  }) async {
    final data = await remoteDataSource.delegateApproval(
      requestId,
      toUserId: toUserId,
      reason: reason,
    );
    return RequestModel.fromJson(data);
  }

  @override
  Future<RequestEntity> cancelRequest(
    String requestId, {
    String? reason,
  }) async {
    final data = await remoteDataSource.cancelRequest(requestId, reason: reason);
    return RequestModel.fromJson(data);
  }

  // ========== LINE ITEMS ==========

  @override
  Future<void> addLineItem(
    String requestId, {
    required String description,
    required int quantity,
    double? unitPrice,
    String? unit,
  }) async {
    await remoteDataSource.addLineItem(requestId, {
      'description': description,
      'quantity': quantity,
      if (unitPrice != null) 'unitPrice': unitPrice,
      if (unit != null) 'unit': unit,
    });
  }

  @override
  Future<void> deleteLineItem(String requestId, String itemId) async {
    await remoteDataSource.deleteLineItem(requestId, itemId);
  }
}

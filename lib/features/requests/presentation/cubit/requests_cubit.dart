import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/domain/repository_result.dart';
import '../../domain/entities/request_entity.dart';
import '../../domain/repositories/request_repository.dart';

part 'requests_state.dart';

class RequestsCubit extends Cubit<RequestsState> {
  final RequestRepository repository;

  RequestsCubit({required this.repository}) : super(RequestsInitial());

  Future<void> loadRequests({
    required String projectId,
    String? userId,
    bool forceRemote = false,
  }) async {
    emit(RequestsLoading());

    try {
      final result = await repository.getMyRequests(
        projectId: projectId,
        userId: userId,
        forceRemote: forceRemote,
      );

      emit(RequestsLoaded(
        requests: result.data,
        source: result.source,
        message: result.message,
        lastSyncedAt: result.lastSyncedAt,
      ));
    } catch (e) {
      emit(RequestsError(message: e.toString()));
    }
  }

  Future<void> loadPendingApprovals({String? projectId}) async {
    emit(RequestsLoading());

    try {
      final result = await repository.getPendingApprovals(projectId: projectId);

      emit(RequestsLoaded(
        requests: result.data,
        source: result.source,
        isPendingApprovals: true,
      ));
    } catch (e) {
      emit(RequestsError(message: e.toString()));
    }
  }

  Future<void> refresh({
    required String projectId,
    String? userId,
  }) async {
    await loadRequests(
      projectId: projectId,
      userId: userId,
      forceRemote: true,
    );
  }

  // ========== WORKFLOW ACTIONS ==========

  Future<void> submitRequest(String requestId) async {
    final currentState = state;
    if (currentState is! RequestsLoaded) return;

    emit(RequestsLoaded(
      requests: currentState.requests,
      source: currentState.source,
      isPerformingAction: true,
      actionRequestId: requestId,
    ));

    try {
      final updatedRequest = await repository.submitRequest(requestId);
      _updateRequestInList(updatedRequest);
    } catch (e) {
      emit(RequestsLoaded(
        requests: currentState.requests,
        source: currentState.source,
        actionError: 'Failed to submit: ${e.toString()}',
      ));
    }
  }

  Future<void> approveRequest(String requestId, {String? comments}) async {
    final currentState = state;
    if (currentState is! RequestsLoaded) return;

    emit(RequestsLoaded(
      requests: currentState.requests,
      source: currentState.source,
      isPerformingAction: true,
      actionRequestId: requestId,
    ));

    try {
      final updatedRequest = await repository.approveRequest(
        requestId,
        comments: comments,
      );
      _updateRequestInList(updatedRequest);
    } catch (e) {
      emit(RequestsLoaded(
        requests: currentState.requests,
        source: currentState.source,
        actionError: 'Failed to approve: ${e.toString()}',
      ));
    }
  }

  Future<void> rejectRequest(
    String requestId, {
    required String reason,
    String? comments,
  }) async {
    final currentState = state;
    if (currentState is! RequestsLoaded) return;

    emit(RequestsLoaded(
      requests: currentState.requests,
      source: currentState.source,
      isPerformingAction: true,
      actionRequestId: requestId,
    ));

    try {
      final updatedRequest = await repository.rejectRequest(
        requestId,
        reason: reason,
        comments: comments,
      );
      _updateRequestInList(updatedRequest);
    } catch (e) {
      emit(RequestsLoaded(
        requests: currentState.requests,
        source: currentState.source,
        actionError: 'Failed to reject: ${e.toString()}',
      ));
    }
  }

  Future<void> cancelRequest(String requestId, {String? reason}) async {
    final currentState = state;
    if (currentState is! RequestsLoaded) return;

    emit(RequestsLoaded(
      requests: currentState.requests,
      source: currentState.source,
      isPerformingAction: true,
      actionRequestId: requestId,
    ));

    try {
      final updatedRequest = await repository.cancelRequest(
        requestId,
        reason: reason,
      );
      _updateRequestInList(updatedRequest);
    } catch (e) {
      emit(RequestsLoaded(
        requests: currentState.requests,
        source: currentState.source,
        actionError: 'Failed to cancel: ${e.toString()}',
      ));
    }
  }

  void _updateRequestInList(RequestEntity updatedRequest) {
    final currentState = state;
    if (currentState is! RequestsLoaded) return;

    final updatedRequests = currentState.requests.map((request) {
      if (request.id == updatedRequest.id ||
          request.serverId == updatedRequest.serverId) {
        return updatedRequest;
      }
      return request;
    }).toList();

    emit(RequestsLoaded(
      requests: updatedRequests,
      source: currentState.source,
    ));
  }
}

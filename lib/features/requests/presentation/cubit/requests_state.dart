part of 'requests_cubit.dart';

abstract class RequestsState extends Equatable {
  const RequestsState();

  @override
  List<Object?> get props => [];
}

class RequestsInitial extends RequestsState {}

class RequestsLoading extends RequestsState {}

class RequestsLoaded extends RequestsState {
  final List<RequestEntity> requests;
  final DataSource source;
  final String? message;
  final int? lastSyncedAt;
  final bool isPendingApprovals;

  // Action state
  final bool isPerformingAction;
  final String? actionRequestId;
  final String? actionError;

  const RequestsLoaded({
    required this.requests,
    this.source = DataSource.remote,
    this.message,
    this.lastSyncedAt,
    this.isPendingApprovals = false,
    this.isPerformingAction = false,
    this.actionRequestId,
    this.actionError,
  });

  @override
  List<Object?> get props => [
        requests,
        source,
        message,
        lastSyncedAt,
        isPendingApprovals,
        isPerformingAction,
        actionRequestId,
        actionError,
      ];
}

class RequestsError extends RequestsState {
  final String message;

  const RequestsError({required this.message});

  @override
  List<Object?> get props => [message];
}

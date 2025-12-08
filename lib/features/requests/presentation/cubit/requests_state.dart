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

  const RequestsLoaded({
    required this.requests,
    required this.source,
    this.message,
    this.lastSyncedAt,
  });

  @override
  List<Object?> get props => [requests, source, message, lastSyncedAt];
}

class RequestsError extends RequestsState {
  final String message;

  const RequestsError({required this.message});

  @override
  List<Object?> get props => [message];
}

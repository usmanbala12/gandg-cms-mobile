part of 'request_create_cubit.dart';

abstract class RequestCreateState extends Equatable {
  const RequestCreateState();

  @override
  List<Object?> get props => [];
}

class RequestCreateInitial extends RequestCreateState {}

class RequestCreateSubmitting extends RequestCreateState {}

class RequestCreateSuccess extends RequestCreateState {}

class RequestCreateError extends RequestCreateState {
  final String message;

  const RequestCreateError({required this.message});

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';

enum LoginStatus {
  idle,
  loading,
  success,
  error,
  mfaRequired,
}

class LoginState extends Equatable {
  final LoginStatus status;
  final String? message;

  const LoginState({
    this.status = LoginStatus.idle,
    this.message,
  });

  LoginState copyWith({
    LoginStatus? status,
    String? message,
  }) {
    return LoginState(
      status: status ?? this.status,
      message: message,
    );
  }

  @override
  List<Object?> get props => [status, message];

  static const initial = LoginState();
}
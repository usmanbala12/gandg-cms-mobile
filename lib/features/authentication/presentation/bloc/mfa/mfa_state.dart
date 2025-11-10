import 'package:equatable/equatable.dart';

enum MfaStatus {
  idle,
  loading,
  success,
  error,
  codeSent,
}

class MfaState extends Equatable {
  final MfaStatus status;
  final String code;
  final String? message;
  final int resendCountdown;

  const MfaState({
    this.status = MfaStatus.idle,
    this.code = '',
    this.message,
    this.resendCountdown = 0,
  });

  MfaState copyWith({
    MfaStatus? status,
    String? code,
    String? message,
    int? resendCountdown,
  }) {
    return MfaState(
      status: status ?? this.status,
      code: code ?? this.code,
      message: message,
      resendCountdown: resendCountdown ?? this.resendCountdown,
    );
  }

  @override
  List<Object?> get props => [status, code, message, resendCountdown];

  static const initial = MfaState(status: MfaStatus.codeSent);
}

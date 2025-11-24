import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when user submits login form
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

/// Triggered when user submits MFA code
class MFARequested extends AuthEvent {
  final String code;
  final String mfaToken;

  const MFARequested({
    required this.code,
    required this.mfaToken,
  });

  @override
  List<Object?> get props => [code, mfaToken];
}

/// Triggered when user requests logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Triggered on app startup to check for biometric login
class CheckBiometricLoginRequested extends AuthEvent {
  const CheckBiometricLoginRequested();
}

/// Triggered when user presses biometric button
class BiometricLoginRequested extends AuthEvent {
  const BiometricLoginRequested();
}

/// Triggered after successful login to ask about biometric setup
class EnableBiometricRequested extends AuthEvent {
  final String email;
  final String refreshToken;

  const EnableBiometricRequested({
    required this.email,
    required this.refreshToken,
  });

  @override
  List<Object?> get props => [email, refreshToken];
}

/// Triggered when user declines biometric setup
class DeclineBiometricRequested extends AuthEvent {
  const DeclineBiometricRequested();
}

import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered on app startup to initial check
class AppStarted extends AuthEvent {
  const AppStarted();
}

/// Triggered when user submits login form
class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

/// Triggered when user submits MFA code during login
class MFARequested extends AuthEvent {
  final String code;
  final String mfaTempToken;

  const MFARequested({required this.code, required this.mfaTempToken});

  @override
  List<Object?> get props => [code, mfaTempToken];
}

/// Triggered when user requests logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Triggered on app startup to check for biometric login availability
class CheckBiometricLoginRequested extends AuthEvent {
  const CheckBiometricLoginRequested();
}

/// Triggered when user presses biometric button
class BiometricLoginRequested extends AuthEvent {
  const BiometricLoginRequested();
}

/// Triggered after successful login to enable biometric
class EnableBiometricRequested extends AuthEvent {
  final String email;
  const EnableBiometricRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// Triggered when user declines biometric setup
class DeclineBiometricRequested extends AuthEvent {
  const DeclineBiometricRequested();
}

// MFA Management (Authenticated Flow)

/// Initialize MFA setup (fetch QR code)
class MfaSetupRequested extends AuthEvent {
  const MfaSetupRequested();
}

/// Complete MFA setup (verify first code)
class MfaEnableRequested extends AuthEvent {
  final String code;
  const MfaEnableRequested(this.code);

  @override
  List<Object?> get props => [code];
}

/// Disable MFA
class MfaDisableRequested extends AuthEvent {
  const MfaDisableRequested();
}

// Password Reset (Unauthenticated Flow)

/// Request password reset email
class PasswordResetRequested extends AuthEvent {
  final String email;
  const PasswordResetRequested(this.email);

  @override
  List<Object?> get props => [email];
}

/// Confirm password reset with token
class PasswordResetConfirmed extends AuthEvent {
  final String token;
  final String newPassword;
  final String confirmPassword;

  const PasswordResetConfirmed({
    required this.token,
    required this.newPassword,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [token, newPassword, confirmPassword];
}

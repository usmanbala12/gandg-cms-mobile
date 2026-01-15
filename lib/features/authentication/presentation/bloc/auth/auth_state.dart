import 'package:equatable/equatable.dart';
import 'package:field_link/features/authentication/domain/entities/user.dart';
import 'package:field_link/features/authentication/data/models/mfa_setup_response_model.dart';

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  mfaRequired,
  mfaSetupPending,
  passwordResetSent,
  passwordResetSuccess,
  biometricPrompt,
  error,
  loggingOut,
  unauthenticated,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;
  final String? message;
  final String? mfaToken;
  final MfaSetupResponse? mfaSetup;
  final bool isBiometricAvailable;

  const AuthState({
    required this.status,
    this.user,
    this.message,
    this.mfaToken,
    this.mfaSetup,
    this.isBiometricAvailable = false,
  });

  /// Initial unauthenticated state
  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  /// Unauthenticated state
  factory AuthState.unauthenticated() {
    return const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Authenticating state
  factory AuthState.authenticating() {
    return const AuthState(status: AuthStatus.authenticating);
  }

  /// Authenticated state with user
  factory AuthState.authenticated(User user) {
    return AuthState(status: AuthStatus.authenticated, user: user);
  }

  /// MFA required state during login
  factory AuthState.mfaRequired(String mfaToken) {
    return AuthState(
      status: AuthStatus.mfaRequired,
      mfaToken: mfaToken,
      message: 'Multi-factor authentication required',
    );
  }

  /// MFA setup state for authenticated user
  factory AuthState.mfaSetupPending(MfaSetupResponse setup) {
    return AuthState(
      status: AuthStatus.mfaSetupPending,
      mfaSetup: setup,
    );
  }

  /// Password reset email sent
  factory AuthState.passwordResetSent(String email) {
    return AuthState(
      status: AuthStatus.passwordResetSent,
      message: 'Password reset link sent to $email',
    );
  }

  /// Password reset successfully confirmed
  factory AuthState.passwordResetSuccess() {
    return const AuthState(
      status: AuthStatus.passwordResetSuccess,
      message: 'Your password has been reset successfully. Please sign in.',
    );
  }

  /// Biometric prompt state
  factory AuthState.biometricPrompt(User user) {
    return AuthState(
      status: AuthStatus.biometricPrompt,
      user: user,
      message: 'Enable biometric login for faster access?',
    );
  }

  /// Error state
  factory AuthState.error(String message) {
    return AuthState(status: AuthStatus.error, message: message);
  }

  /// Logging out state
  factory AuthState.loggingOut() {
    return const AuthState(status: AuthStatus.loggingOut);
  }

  /// Copy with method for immutability
  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? message,
    String? mfaToken,
    MfaSetupResponse? mfaSetup,
    bool? isBiometricAvailable,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: message,
      mfaToken: mfaToken ?? this.mfaToken,
      mfaSetup: mfaSetup ?? this.mfaSetup,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
    );
  }

  @override
  List<Object?> get props => [
    status,
    user,
    message,
    mfaToken,
    mfaSetup,
    isBiometricAvailable,
  ];
}

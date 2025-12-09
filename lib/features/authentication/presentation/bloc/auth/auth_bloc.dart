import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:field_link/core/services/token_storage_service.dart';
import 'package:field_link/core/utils/biometrics/biometric_auth_service.dart';
import 'package:field_link/features/authentication/domain/entities/user.dart';
import 'package:field_link/features/authentication/domain/usecases/login_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/verify_mfa_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/refresh_token_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final VerifyMFAUseCase verifyMFAUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final BiometricAuthService biometricAuthService;
  final TokenStorageService tokenStorageService;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.verifyMFAUseCase,
    required this.refreshTokenUseCase,
    required this.biometricAuthService,
    required this.tokenStorageService,
  }) : super(AuthState.initial()) {
    on<LoginRequested>(_onLoginRequested);
    on<MFARequested>(_onMFARequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckBiometricLoginRequested>(_onCheckBiometricLoginRequested);
    on<BiometricLoginRequested>(_onBiometricLoginRequested);
    on<EnableBiometricRequested>(_onEnableBiometricRequested);
    on<DeclineBiometricRequested>(_onDeclineBiometricRequested);
  }

  /// Handle login request
  FutureOr<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Validate input
    if (event.email.isEmpty || !event.email.contains('@')) {
      emit(AuthState.error('Please enter a valid email address'));
      return;
    }
    if (event.password.isEmpty || event.password.length < 6) {
      emit(AuthState.error('Password must be at least 6 characters'));
      return;
    }

    emit(AuthState.authenticating());

    final result = await loginUseCase(event.email, event.password);

    result.fold(
      (failure) {
        emit(AuthState.error(failure.message));
      },
      (user) {
        // Check if MFA is required by checking if we have tokens
        // For now, we'll emit authenticated and let the UI handle MFA flow
        emit(AuthState.authenticated(user));
      },
    );
  }

  /// Handle MFA verification
  FutureOr<void> _onMFARequested(
    MFARequested event,
    Emitter<AuthState> emit,
  ) async {
    if (event.code.isEmpty || event.code.length != 6) {
      emit(AuthState.error('Please enter a valid 6-digit code'));
      return;
    }

    emit(AuthState.authenticating());

    final result = await verifyMFAUseCase(event.code, event.mfaToken);

    result.fold(
      (failure) {
        emit(AuthState.error(failure.message));
      },
      (_) {
        // After MFA verification, we need to fetch user data
        // For now, emit authenticated with a placeholder user
        // TODO: Fetch user data from /me endpoint
        emit(
          AuthState.authenticated(
            const User(
                id: 'user_id', email: 'user@example.com', fullName: 'User'),
          ),
        );
      },
    );
  }

  /// Handle logout
  FutureOr<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loggingOut());

    final result = await logoutUseCase();

    result.fold(
      (failure) {
        // Even if logout fails on server, clear local state
        emit(AuthState.unauthenticated());
      },
      (_) {
        emit(AuthState.unauthenticated());
      },
    );
  }

  /// Check for biometric login on app startup
  FutureOr<void> _onCheckBiometricLoginRequested(
    CheckBiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Check if biometric is enabled
      final isBiometricEnabled = await tokenStorageService.isBiometricEnabled();
      if (!isBiometricEnabled) {
        emit(AuthState.unauthenticated());
        return;
      }

      // Check if biometric is available on device
      final isBiometricAvailable = await biometricAuthService.isAvailable();
      if (!isBiometricAvailable) {
        emit(AuthState.unauthenticated());
        return;
      }

      // Get stored refresh token
      final refreshToken = await tokenStorageService.getRefreshToken();
      if (refreshToken == null) {
        emit(AuthState.unauthenticated());
        return;
      }

      emit(state.copyWith(isBiometricAvailable: true));
    } catch (e) {
      emit(AuthState.unauthenticated());
    }
  }

  /// Handle biometric login
  FutureOr<void> _onBiometricLoginRequested(
    BiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthState.authenticating());

      // Authenticate with biometrics
      final result = await biometricAuthService.authenticate(
        reason: 'Sign in with biometrics',
      );

      if (!result.success) {
        emit(
          AuthState.error(result.error ?? 'Biometric authentication failed'),
        );
        return;
      }

      // Get stored refresh token
      final refreshToken = await tokenStorageService.getRefreshToken();
      if (refreshToken == null) {
        emit(AuthState.error('No stored credentials found'));
        return;
      }

      // Refresh token to get new access token
      final refreshResult = await refreshTokenUseCase(refreshToken);

      refreshResult.fold(
        (failure) {
          emit(AuthState.error(failure.message));
        },
        (_) {
          // TODO: Fetch user data from /me endpoint
          emit(
            AuthState.authenticated(
              const User(
                id: 'user_id',
                email: 'user@example.com',
                fullName: 'User',
              ),
            ),
          );
        },
      );
    } catch (e) {
      emit(AuthState.error('Biometric authentication error: $e'));
    }
  }

  /// Handle enabling biometric after login
  FutureOr<void> _onEnableBiometricRequested(
    EnableBiometricRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await tokenStorageService.setBiometricEnabled(true);
      await tokenStorageService.setUserEmail(event.email);
      emit(
        AuthState.authenticated(
          User(id: 'user_id', email: event.email, fullName: 'User'),
        ),
      );
    } catch (e) {
      emit(AuthState.error('Failed to enable biometric: $e'));
    }
  }

  /// Handle declining biometric setup
  FutureOr<void> _onDeclineBiometricRequested(
    DeclineBiometricRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await tokenStorageService.setBiometricEnabled(false);
      emit(
        AuthState.authenticated(
          const User(
              id: 'user_id', email: 'user@example.com', fullName: 'User'),
        ),
      );
    } catch (e) {
      emit(AuthState.error('Failed to update biometric settings: $e'));
    }
  }
}

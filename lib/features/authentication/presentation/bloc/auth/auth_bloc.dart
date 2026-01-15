import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:field_link/core/services/token_storage_service.dart';
import 'package:field_link/core/services/token_refresh_service.dart';
import 'package:field_link/core/utils/biometrics/biometric_auth_service.dart';
import 'package:field_link/features/authentication/domain/usecases/login_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/verify_mfa_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/refresh_token_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/setup_mfa_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/enable_mfa_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/disable_mfa_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/request_password_reset_usecase.dart';
import 'package:field_link/features/authentication/domain/usecases/confirm_password_reset_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final VerifyMFAUseCase verifyMFAUseCase;
  final RefreshTokenUseCase refreshTokenUseCase;
  final SetupMfaUseCase setupMfaUseCase;
  final EnableMfaUseCase enableMfaUseCase;
  final DisableMfaUseCase disableMfaUseCase;
  final RequestPasswordResetUseCase requestPasswordResetUseCase;
  final ConfirmPasswordResetUseCase confirmPasswordResetUseCase;
  
  final BiometricAuthService biometricAuthService;
  final TokenStorageService tokenStorageService;
  final TokenRefreshService tokenRefreshService;
  
  StreamSubscription<void>? _logoutSubscription;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.verifyMFAUseCase,
    required this.refreshTokenUseCase,
    required this.setupMfaUseCase,
    required this.enableMfaUseCase,
    required this.disableMfaUseCase,
    required this.requestPasswordResetUseCase,
    required this.confirmPasswordResetUseCase,
    required this.biometricAuthService,
    required this.tokenStorageService,
    required this.tokenRefreshService,
  }) : super(const AuthState(status: AuthStatus.initial)) {
    on<AppStarted>(_onAppStarted);
    on<LoginRequested>(_onLoginRequested);
    on<MFARequested>(_onMFARequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckBiometricLoginRequested>(_onCheckBiometricLoginRequested);
    on<BiometricLoginRequested>(_onBiometricLoginRequested);
    on<EnableBiometricRequested>(_onEnableBiometricRequested);
    on<DeclineBiometricRequested>(_onDeclineBiometricRequested);
    on<MfaSetupRequested>(_onMfaSetupRequested);
    on<MfaEnableRequested>(_onMfaEnableRequested);
    on<MfaDisableRequested>(_onMfaDisableRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<PasswordResetConfirmed>(_onPasswordResetConfirmed);

    _logoutSubscription = tokenStorageService.logoutStream.listen((_) {
      add(const LogoutRequested());
    });
  }

  @override
  Future<void> close() {
    _logoutSubscription?.cancel();
    return super.close();
  }

  FutureOr<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    final isAuthenticated = await tokenStorageService.isAuthenticated();
    if (isAuthenticated) {
      final user = await tokenStorageService.getUser();
      if (user != null) {
        emit(AuthState.authenticated(user));
        tokenRefreshService.start();
        return;
      }
    }
    emit(AuthState.unauthenticated());
  }

  FutureOr<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.authenticating());

    final result = await loginUseCase(event.email, event.password);

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (response) {
        if (response.mfaRequired && response.mfaTempToken != null) {
          emit(AuthState.mfaRequired(response.mfaTempToken!));
        } else if (response.user != null) {
          emit(AuthState.authenticated(response.user!));
          tokenRefreshService.start();
          
          // Check for biometric setup after successful login
          add(const CheckBiometricLoginRequested());
        }
      },
    );
  }

  FutureOr<void> _onMFARequested(
    MFARequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.authenticating());

    final result = await verifyMFAUseCase(event.code, event.mfaTempToken);

    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (response) {
        if (response.user != null) {
          emit(AuthState.authenticated(response.user!));
          tokenRefreshService.start();
        } else {
          emit(AuthState.error('MFA verification failed: No user data returned'));
        }
      },
    );
  }

  FutureOr<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.loggingOut());
    await logoutUseCase();
    tokenRefreshService.stop();
    emit(AuthState.unauthenticated());
  }

  FutureOr<void> _onCheckBiometricLoginRequested(
    CheckBiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    final canUseBiometrics = await biometricAuthService.isAvailable();
    final isEnabled = await tokenStorageService.isBiometricEnabled();
    
    if (canUseBiometrics && isEnabled) {
      emit(state.copyWith(isBiometricAvailable: true));
    }
  }

  FutureOr<void> _onBiometricLoginRequested(
    BiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.authenticating());
    
    final authResult = await biometricAuthService.authenticate(
      reason: 'Sign in to Field Link',
    );

    if (authResult.success) {
      final refreshToken = await tokenStorageService.getRefreshToken();
      if (refreshToken != null) {
        final result = await refreshTokenUseCase(refreshToken);
        result.fold(
          (failure) => emit(AuthState.error(failure.message)),
          (response) {
            if (response.user != null) {
              emit(AuthState.authenticated(response.user!));
              tokenRefreshService.start();
            }
          },
        );
      } else {
        emit(AuthState.unauthenticated());
      }
    } else {
      emit(AuthState.error(authResult.error ?? 'Biometric authentication failed'));
    }
  }

  FutureOr<void> _onEnableBiometricRequested(
    EnableBiometricRequested event,
    Emitter<AuthState> emit,
  ) async {
    await tokenStorageService.setBiometricEnabled(true);
    await tokenStorageService.setUserEmail(event.email);
    // Stay in authenticated state
  }

  FutureOr<void> _onDeclineBiometricRequested(
    DeclineBiometricRequested event,
    Emitter<AuthState> emit,
  ) async {
    await tokenStorageService.setBiometricEnabled(false);
  }

  FutureOr<void> _onMfaSetupRequested(
    MfaSetupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.authenticating());
    final result = await setupMfaUseCase();
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (setup) => emit(AuthState.mfaSetupPending(setup)),
    );
  }

  FutureOr<void> _onMfaEnableRequested(
    MfaEnableRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.authenticating());
    final result = await enableMfaUseCase(event.code);
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) {
        // Refresh current user state to show MFA is enabled
        add(AppStarted()); 
      },
    );
  }

  FutureOr<void> _onMfaDisableRequested(
    MfaDisableRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.authenticating());
    final result = await disableMfaUseCase();
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => add(AppStarted()),
    );
  }

  FutureOr<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.authenticating());
    final result = await requestPasswordResetUseCase(event.email);
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => emit(AuthState.passwordResetSent(event.email)),
    );
  }

  FutureOr<void> _onPasswordResetConfirmed(
    PasswordResetConfirmed event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthState.authenticating());
    final result = await confirmPasswordResetUseCase(
      token: event.token,
      newPassword: event.newPassword,
      confirmPassword: event.confirmPassword,
    );
    result.fold(
      (failure) => emit(AuthState.error(failure.message)),
      (_) => emit(AuthState.passwordResetSuccess()),
    );
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:field_link/core/utils/biometrics/biometric_auth_service.dart';

import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final BiometricAuthService _biometricAuthService;

  LoginBloc({BiometricAuthService? biometricAuthService})
      : _biometricAuthService = biometricAuthService ?? BiometricAuthService(),
        super(LoginState.initial) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<BiometricButtonPressed>(_onBiometricButtonPressed);
  }

  FutureOr<void> _onLoginButtonPressed(
    LoginButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    // Basic validation
    if (event.email.isEmpty || !event.email.contains('@')) {
      emit(
        state.copyWith(
          status: LoginStatus.error,
          message: 'Please enter a valid email.',
        ),
      );
      return;
    }
    if (event.password.isEmpty || event.password.length < 6) {
      emit(
        state.copyWith(
          status: LoginStatus.error,
          message: 'Password must be at least 6 characters.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading, message: null));

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      if (event.email == 'mfa@example.com') {
        emit(
          state.copyWith(
            status: LoginStatus.mfaRequired,
            message: 'Multi-factor authentication required.',
          ),
        );
        return;
      }

      if (event.email == 'user@example.com' &&
          event.password == 'Password123!') {
        emit(state.copyWith(status: LoginStatus.success));
      } else {
        emit(
          state.copyWith(
            status: LoginStatus.error,
            message: 'Invalid email or password.',
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          status: LoginStatus.error,
          message: 'An unexpected error occurred. Please try again.',
        ),
      );
    }
  }

  FutureOr<void> _onBiometricButtonPressed(
    BiometricButtonPressed event,
    Emitter<LoginState> emit,
  ) async {
    print('[LoginBloc] Biometric button pressed');

    // Check if biometrics are available
    final available = await _biometricAuthService.isAvailable();
    if (!available) {
      print('[LoginBloc] Biometrics not available');
      emit(state.copyWith(
        status: LoginStatus.error,
        message: 'Biometrics not available on this device.',
      ));
      return;
    }

    // Get available biometric types for debugging
    final biometrics = await _biometricAuthService.getAvailableBiometrics();
    print('[LoginBloc] Available biometrics: $biometrics');

    emit(state.copyWith(status: LoginStatus.loading, message: null));

    try {
      print('[LoginBloc] Attempting biometric authentication...');

      // Attempt biometric authentication with detailed error handling
      final result = await _biometricAuthService.authenticate(
        reason: 'Sign in with biometrics',
      );

      print('[LoginBloc] Biometric result - Success: ${result.success}, Error: ${result.error}');

      if (result.success) {
        emit(state.copyWith(status: LoginStatus.success));
      } else {
        emit(state.copyWith(
          status: LoginStatus.error,
          message: result.error ?? 'Biometric authentication failed or was canceled.',
        ));
      }
    } catch (e) {
      print('[LoginBloc] Exception during biometric authentication: $e');
      emit(state.copyWith(
        status: LoginStatus.error,
        message: 'An error occurred during biometric authentication: $e',
      ));
    }
  }
}

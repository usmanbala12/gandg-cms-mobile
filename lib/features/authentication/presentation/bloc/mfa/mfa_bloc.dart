import 'dart:async';

import 'package:bloc/bloc.dart';

import 'mfa_event.dart';
import 'mfa_state.dart';

class MfaBloc extends Bloc<MfaEvent, MfaState> {
  MfaBloc() : super(MfaState.initial) {
    on<CodeChanged>(_onCodeChanged);
    on<SubmitPressed>(_onSubmitPressed);
    on<ResendPressed>(_onResendPressed);
  }

  FutureOr<void> _onCodeChanged(
    CodeChanged event,
    Emitter<MfaState> emit,
  ) {
    // Only allow numeric input and max 6 characters
    final sanitized = event.code.replaceAll(RegExp(r'[^0-9]'), '');
    final truncated = sanitized.length > 6 ? sanitized.substring(0, 6) : sanitized;
    emit(state.copyWith(code: truncated));
  }

  FutureOr<void> _onSubmitPressed(
    SubmitPressed event,
    Emitter<MfaState> emit,
  ) async {
    if (state.code.length != 6) {
      emit(state.copyWith(
        status: MfaStatus.error,
        message: 'Please enter a 6-digit code.',
      ));
      return;
    }

    emit(state.copyWith(status: MfaStatus.loading, message: null));

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Dummy verification: accept code '123456'
      if (state.code == '123456') {
        emit(state.copyWith(status: MfaStatus.success));
      } else {
        emit(state.copyWith(
          status: MfaStatus.error,
          message: 'Invalid verification code. Please try again.',
        ));
      }
    } catch (_) {
      emit(state.copyWith(
        status: MfaStatus.error,
        message: 'An error occurred. Please try again.',
      ));
    }
  }

  FutureOr<void> _onResendPressed(
    ResendPressed event,
    Emitter<MfaState> emit,
  ) async {
    emit(state.copyWith(status: MfaStatus.loading, message: null));

    // Simulate sending code
    await Future.delayed(const Duration(seconds: 1));

    emit(state.copyWith(
      status: MfaStatus.codeSent,
      message: 'Verification code sent to your email.',
      resendCountdown: 60,
    ));

    // Countdown timer
    for (int i = 60; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(resendCountdown: i - 1));
    }
  }
}

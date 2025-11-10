import 'package:field_link/features/home/presentation/pages/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import '../bloc/mfa/mfa_bloc.dart';
import '../bloc/mfa/mfa_event.dart';
import '../bloc/mfa/mfa_state.dart';

class MfaScreen extends StatelessWidget {
  const MfaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MfaBloc>(
      create: (_) => MfaBloc(),
      child: const _MfaView(),
    );
  }
}

class _MfaView extends StatefulWidget {
  const _MfaView();

  @override
  State<_MfaView> createState() => _MfaViewState();
}

class _MfaViewState extends State<_MfaView> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : [const Color(0xFFF5F7FA), const Color(0xFFE4ECF7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: BlocConsumer<MfaBloc, MfaState>(
                  listenWhen: (prev, curr) => prev.status != curr.status,
                  listener: (context, state) {
                    if (state.status == MfaStatus.success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Verification successful!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      // Navigate to home
                      Get.off(() => const HomeScreen());
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state.status == MfaStatus.loading;
                    final canResend = state.resendCountdown == 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Back Button
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Icon
                        Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.primaryColor.withOpacity(0.1),
                            ),
                            child: Icon(
                              Icons.verified_user_outlined,
                              size: 40,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Title
                        Text(
                          'Verify Your Identity',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          'Enter the 6-digit code sent to your email',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Card with form
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Code Input Field
                                TextFormField(
                                  controller: _codeController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  enabled: !isLoading,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        letterSpacing: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  decoration: InputDecoration(
                                    labelText: 'Verification Code',
                                    hintText: '000000',
                                    counterText: '',
                                    prefixIcon: const Icon(
                                      Icons.verified_user_outlined,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  onChanged: (value) {
                                    context.read<MfaBloc>().add(
                                      CodeChanged(value),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),

                                // Error Message
                                if (state.status == MfaStatus.error &&
                                    state.message != null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.error
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: theme.colorScheme.error
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      state.message!,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: theme.colorScheme.error,
                                          ),
                                    ),
                                  ),

                                // Success Message
                                if (state.status == MfaStatus.codeSent &&
                                    state.message != null)
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Colors.green.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Text(
                                      state.message!,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: Colors.green),
                                    ),
                                  ),
                                const SizedBox(height: 24),

                                // Verify Button
                                ElevatedButton(
                                  onPressed:
                                      (state.code.length == 6 && !isLoading)
                                      ? () => context.read<MfaBloc>().add(
                                          const SubmitPressed(),
                                        )
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(56),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'Verify',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                                const SizedBox(height: 16),

                                // Resend Code Button
                                OutlinedButton(
                                  onPressed: (canResend && !isLoading)
                                      ? () => context.read<MfaBloc>().add(
                                          const ResendPressed(),
                                        )
                                      : null,
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    canResend
                                        ? 'Resend Code'
                                        : 'Resend in ${state.resendCountdown}s',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Dev Hint
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.primaryColor.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            'Demo Code: 123456',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

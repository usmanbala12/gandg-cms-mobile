import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import 'login_page.dart';

class BiometricLoginPage extends StatefulWidget {
  const BiometricLoginPage({super.key});

  @override
  State<BiometricLoginPage> createState() => _BiometricLoginPageState();
}

class _BiometricLoginPageState extends State<BiometricLoginPage> {
  @override
  void initState() {
    super.initState();
    // Trigger biometric check on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthBloc>().add(const CheckBiometricLoginRequested());
    });
  }

  void _handleBiometricLogin(BuildContext context) {
    context.read<AuthBloc>().add(const BiometricLoginRequested());
  }

  void _handleSkip(BuildContext context) {
    Get.off(() => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            if (state.status == AuthStatus.error && state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: theme.colorScheme.error,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else if (state.status == AuthStatus.unauthenticated) {
              // No biometric available, go to login
              Get.off(() => const LoginPage());
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 64,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.fingerprint,
                          size: 64,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Quick Access',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use your biometrics to sign in quickly',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 64),

                  // Buttons
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading =
                          state.status == AuthStatus.authenticating;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Biometric Button
                          ElevatedButton.icon(
                            icon: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.fingerprint),
                            label: const Text('Sign in with Biometrics'),
                            onPressed: isLoading
                                ? null
                                : () => _handleBiometricLogin(context),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(56),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Skip Button
                          OutlinedButton(
                            onPressed:
                                isLoading ? null : () => _handleSkip(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: const Text('Use Email Instead'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

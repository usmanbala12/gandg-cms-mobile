import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../widgets/auth_text_field.dart';
import 'mfa_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin(BuildContext context) {
    context.read<AuthBloc>().add(
          LoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  void _handleBiometric(BuildContext context) {
    context.read<AuthBloc>().add(const BiometricLoginRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listenWhen: (prev, curr) => prev.status != curr.status,
          listener: (context, state) {
            if (state.status == AuthStatus.mfaRequired) {
              Get.to(() => MFAPage(mfaToken: state.mfaToken ?? ''));
            } else if (state.status == AuthStatus.error &&
                state.message != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message!),
                  backgroundColor: theme.colorScheme.error,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 32,
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
                          Icons.lock_outline,
                          size: 48,
                          color: theme.primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Field Link',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sign in to your account',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Form
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading =
                          state.status == AuthStatus.authenticating;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Email Field
                          AuthTextField(
                            controller: _emailController,
                            label: 'Email',
                            hint: 'user@example.com',
                            prefixIcon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          AuthTextField(
                            controller: _passwordController,
                            label: 'Password',
                            prefixIcon: Icons.lock_outline,
                            obscureText: true,
                            enabled: !isLoading,
                          ),
                          const SizedBox(height: 24),

                          // Sign In Button
                          ElevatedButton(
                            onPressed:
                                isLoading ? null : () => _handleLogin(context),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: theme.dividerColor,
                                  height: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'or',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: theme.dividerColor,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Biometric Button
                          OutlinedButton.icon(
                            icon: const Icon(Icons.fingerprint),
                            label: const Text('Sign in with Biometrics'),
                            onPressed: isLoading
                                ? null
                                : () => _handleBiometric(context),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Forgot Password
                          Center(
                            child: TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      // TODO: Navigate to forgot password
                                    },
                              child: const Text('Forgot password?'),
                            ),
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

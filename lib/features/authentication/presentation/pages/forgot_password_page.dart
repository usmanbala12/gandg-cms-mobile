import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../widgets/auth_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar('Error', 'Please enter a valid email address');
      return;
    }
    context.read<AuthBloc>().add(PasswordResetRequested(email));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.passwordResetSent) {
            Get.snackbar('Success', state.message ?? 'Reset link sent');
            Get.back();
          } else if (state.status == AuthStatus.error) {
            Get.snackbar('Error', state.message ?? 'An error occurred');
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Forgot your password?',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter your email address and we will send you a link to reset your password.',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              AuthTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'your@email.com',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 32),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final isLoading = state.status == AuthStatus.authenticating;
                  return ElevatedButton(
                    onPressed: isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Send Reset Link'),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:field_link/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:field_link/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:field_link/features/authentication/presentation/pages/biometric_login_page.dart';
import 'package:field_link/features/authentication/presentation/pages/login_page.dart';
//import 'package:field_link/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:field_link/navigation_menu.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // If authenticated, show home
        if (state.status == AuthStatus.authenticated) {
          return const NavigationMenu();
        }

        // If biometric is available, show biometric login
        if (state.isBiometricAvailable && state.status != AuthStatus.error) {
          return const BiometricLoginPage();
        }

        // Default to login page
        return const LoginPage();
      },
    );
  }
}

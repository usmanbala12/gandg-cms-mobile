import 'package:field_link/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:field_link/features/authentication/presentation/bloc/auth/auth_state.dart';
import 'package:field_link/features/authentication/presentation/pages/biometric_login_page.dart';
import 'package:field_link/features/authentication/presentation/pages/login_page.dart';
import 'package:field_link/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:field_link/features/issues/presentation/bloc/issues_bloc.dart';
import 'package:field_link/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:field_link/features/requests/presentation/cubit/requests_cubit.dart';
import 'package:field_link/features/requests/presentation/cubit/request_create_cubit.dart';
import 'package:field_link/features/reports/presentation/cubit/reports_cubit.dart';
import 'package:field_link/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:field_link/navigation_menu.dart';
import 'package:field_link/core/di/injection_container.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isBiometricAvailable != current.isBiometricAvailable,
      builder: (context, state) {
        // If authenticated, show home
        if (state.status == AuthStatus.authenticated) {
          return MultiBlocProvider(
            providers: [
              BlocProvider<DashboardCubit>(
                create: (_) => sl<DashboardCubit>(),
              ),
              BlocProvider<IssuesBloc>(
                create: (_) => sl<IssuesBloc>(),
              ),
              BlocProvider<RequestsCubit>(
                create: (_) => sl<RequestsCubit>(),
              ),
              BlocProvider<RequestCreateCubit>(
                create: (_) => sl<RequestCreateCubit>(),
              ),
              BlocProvider<NotificationsCubit>(
                create: (_) => sl<NotificationsCubit>(),
              ),
              BlocProvider<ReportsCubit>(
                create: (context) => sl<ReportsCubit>(
                  param1: context.read<DashboardCubit>(),
                ),
              ),
              BlocProvider<ProfileCubit>(
                create: (_) => sl<ProfileCubit>()..init(),
              ),
            ],
            child: const NavigationMenu(),
          );
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

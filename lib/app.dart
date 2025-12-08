import 'package:field_link/app_home.dart';
import 'package:field_link/core/di/injection_container.dart';
import 'package:field_link/core/utils/theme/theme.dart';
import 'package:field_link/features/authentication/presentation/bloc/auth/auth_bloc.dart';
import 'package:field_link/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:field_link/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => sl<AuthBloc>(),
        ),
        BlocProvider<DashboardCubit>(
          create: (_) => sl<DashboardCubit>()..init(),
        ),
        BlocProvider<SettingsCubit>(
          create: (_) => sl<SettingsCubit>()..loadStorageInfo(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (previous, current) =>
            previous.themeMode != current.themeMode,
        builder: (context, state) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: state.themeMode,
            theme: TAppTheme.lightTheme,
            darkTheme: TAppTheme.darkTheme,
            home: AppHome(),
          );
        },
      ),
    );
  }
}

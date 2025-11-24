import 'package:field_link/app_home.dart';
import 'package:field_link/core/di/injection_container.dart';
import 'package:field_link/core/utils/theme/theme.dart';
import 'package:field_link/features/authentication/presentation/bloc/auth/auth_bloc.dart';
// import 'package:field_link/features/authentication/presentation/bloc/auth/auth_state.dart';
// import 'package:field_link/features/authentication/presentation/pages/biometric_login_page.dart';
// import 'package:field_link/features/authentication/presentation/pages/login_page.dart';
// import 'package:field_link/features/dashboard/presentation/pages/dashboard_page.dart';
//import 'package:field_link/navigation_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>(),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: TAppTheme.lightTheme,
        darkTheme: TAppTheme.darkTheme,
        home: AppHome(),
      ),
    );
  }
}

import 'package:field_link/core/di/injection_container.dart';
import 'package:field_link/core/utils/constants/colors.dart';
import 'package:field_link/core/utils/helpers/helper_function.dart';
import 'package:field_link/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:field_link/features/more/presentation/pages/more_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:field_link/features/reports/presentation/pages/reports_list_page.dart';
import 'package:field_link/features/issues/presentation/bloc/issues_bloc.dart';
import 'package:field_link/features/issues/presentation/pages/issues_list_page.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      NavigationController(initialIndex: initialIndex),
    );
    final darkMode = ThelperFunctions.isDarkMode(context);
    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBar(
          height: 60,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) =>
              controller.selectedIndex.value = index,
          backgroundColor: darkMode ? AppColors.dark : Colors.white,
          indicatorColor: darkMode
              ? AppColors.white.withOpacity(0.1)
              : AppColors.dark.withOpacity(0.1),
          destinations: [
            NavigationDestination(
              icon: Icon(
                Icons.home,
                color: darkMode
                    ? AppColors.white.withOpacity(0.6)
                    : AppColors.textsecondary,
              ),
              selectedIcon: Icon(
                Icons.home,
                color: darkMode ? AppColors.white : AppColors.primary,
              ),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.flag,
                color: darkMode
                    ? AppColors.white.withOpacity(0.6)
                    : AppColors.textsecondary,
              ),
              selectedIcon: Icon(
                Icons.flag,
                color: darkMode ? AppColors.white : AppColors.primary,
              ),
              label: 'Report',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.report,
                color: darkMode
                    ? AppColors.white.withOpacity(0.6)
                    : AppColors.textsecondary,
              ),
              selectedIcon: Icon(
                Icons.report,
                color: darkMode ? AppColors.white : AppColors.primary,
              ),
              label: 'Issues',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.more,
                color: darkMode
                    ? AppColors.white.withOpacity(0.6)
                    : AppColors.textsecondary,
              ),
              selectedIcon: Icon(
                Icons.more,
                color: darkMode ? AppColors.white : AppColors.primary,
              ),
              label: 'More',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person,
                color: darkMode
                    ? AppColors.white.withOpacity(0.6)
                    : AppColors.textsecondary,
              ),
              selectedIcon: Icon(
                Icons.person,
                color: darkMode ? AppColors.white : AppColors.primary,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex;

  NavigationController({int initialIndex = 0})
      : selectedIndex = initialIndex.obs;

  final screens = [
    const DashboardPage(),
    const ReportsListPage(),
    BlocProvider(
      create: (_) => sl<IssuesBloc>(),
      child: const IssuesListPage(),
    ),
    const MorePage(),
    const DashboardPage(),
  ];
}

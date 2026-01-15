import 'package:field_link/core/utils/constants/colors.dart';
import 'package:field_link/core/utils/helpers/helper_function.dart';
import 'package:field_link/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:field_link/features/more/presentation/pages/more_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:field_link/features/reports/presentation/pages/reports_list_page.dart';
import 'package:field_link/features/issues/presentation/pages/issues_list_page.dart';
import 'package:field_link/features/profile/presentation/pages/profile_page.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      NavigationController(initialIndex: initialIndex),
    );
    final darkMode = ThelperFunctions.isDarkMode(context);
    
    // Pre-compute colors once
    final unselectedColor = darkMode
        ? AppColors.white.withValues(alpha: 0.6)
        : AppColors.textsecondary;
    final selectedColor = darkMode ? AppColors.white : AppColors.primary;
    
    return Scaffold(
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return IconThemeData(color: selectedColor);
            }
            return IconThemeData(color: unselectedColor);
          }),
        ),
        child: Obx(
          () => NavigationBar(
            height: 60,
            elevation: 0,
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) =>
                controller.selectedIndex.value = index,
            backgroundColor: darkMode ? AppColors.dark : Colors.white,
            indicatorColor: darkMode
                ? AppColors.white.withValues(alpha: 0.1)
                : AppColors.dark.withValues(alpha: 0.1),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.flag_outlined),
                selectedIcon: Icon(Icons.flag),
                label: 'Report',
              ),
              NavigationDestination(
                icon: Icon(Icons.report_outlined),
                selectedIcon: Icon(Icons.report),
                label: 'Issues',
              ),
              NavigationDestination(
                icon: Icon(Icons.more_horiz_outlined),
                selectedIcon: Icon(Icons.more_horiz),
                label: 'More',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
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

  late final screens = [
    const DashboardPage(),
    const ReportsListPage(),
    const IssuesListPage(),
    const MorePage(),
    const ProfilePage(),
  ];
}

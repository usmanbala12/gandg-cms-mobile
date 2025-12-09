import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SettingsCubit>()..loadStorageInfo(),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: Theme.of(context).textTheme.titleLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme,
      ),
      body: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state.status == SettingsStatus.syncSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sync completed successfully')),
            );
          } else if (state.status == SettingsStatus.syncError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sync error: ${state.errorMessage}')),
            );
          }
        },
        child: ListView(
          children: [
            _buildSectionHeader(context, 'Sync & Storage'),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                String cacheSize = state.cacheSize;
                String mediaSize = state.mediaSize;
                String lastSync = state.lastSyncTime != null
                    ? state.lastSyncTime.toString()
                    : 'Never';

                return Column(
                  children: [
                    ListTile(
                      title: const Text('Sync Now'),
                      subtitle: Text('Last synced: $lastSync'),
                      trailing: state.status == SettingsStatus.syncing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.sync),
                      onTap: state.status == SettingsStatus.syncing
                          ? null
                          : () {
                              final dashboardState =
                                  context.read<DashboardCubit>().state;
                              if (dashboardState.selectedProjectId != null) {
                                context.read<SettingsCubit>().triggerSync(
                                      dashboardState.selectedProjectId!,
                                    );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No active project'),
                                  ),
                                );
                              }
                            },
                    ),
                    ListTile(
                      title: const Text('Clear Cache'),
                      subtitle: Text('Cache size: $cacheSize'),
                      onTap: () {
                        // TODO: Implement clear cache
                      },
                    ),
                    ListTile(
                      title: const Text('Media Storage'),
                      subtitle: Text('Used: $mediaSize'),
                      onTap: () {
                        // TODO: Manage media
                      },
                    ),
                  ],
                );
              },
            ),
            const Divider(),
            _buildSectionHeader(context, 'App Settings'),
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, state) {
                final isDark = state.themeMode == ThemeMode.dark;
                return SwitchListTile(
                  title: const Text('Dark Mode'),
                  value: isDark,
                  onChanged: (value) {
                    context.read<SettingsCubit>().toggleTheme(value);
                  },
                );
              },
            ),
            const Divider(),
            // ListTile(
            //   title: const Text(
            //     'Sign Out',
            //     style: TextStyle(color: Colors.red),
            //   ),
            //   leading: const Icon(Icons.logout, color: Colors.red),
            //   onTap: () {
            //     // TODO: Trigger logout
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

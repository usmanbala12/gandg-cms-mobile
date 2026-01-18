import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../dashboard/presentation/bloc/dashboard_cubit.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocListener<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state.status == SettingsStatus.syncSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Sync completed successfully'),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state.status == SettingsStatus.syncError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sync error: ${state.errorMessage}'),
                backgroundColor: theme.colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            // Appearance Section
            _buildSectionCard(
              context,
              icon: Icons.palette_outlined,
              iconColor: Colors.purple,
              title: 'Appearance',
              children: [
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, state) {
                    final isDark = state.themeMode == ThemeMode.dark;
                    return _buildSwitchTile(
                      context,
                      icon: isDark ? Icons.dark_mode : Icons.light_mode,
                      title: 'Dark Mode',
                      subtitle: isDark ? 'Dark theme enabled' : 'Light theme enabled',
                      value: isDark,
                      onChanged: (value) {
                        context.read<SettingsCubit>().toggleTheme(value);
                      },
                    );
                  },
                ),
              ],
            ),

            // Sync Section
            _buildSectionCard(
              context,
              icon: Icons.sync,
              iconColor: Colors.blue,
              title: 'Sync',
              children: [
                BlocBuilder<SettingsCubit, SettingsState>(
                  builder: (context, state) {
                    final lastSync = state.lastSyncTime != null
                        ? _formatDateTime(state.lastSyncTime!)
                        : 'Never';

                    return _buildActionTile(
                      context,
                      icon: Icons.sync,
                      title: 'Sync Now',
                      subtitle: 'Last synced: $lastSync',
                      trailing: state.status == SettingsStatus.syncing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
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
                                    content: Text('No active project selected'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                    );
                  },
                ),
              ],
            ),

            // Storage Section
            _buildSectionCard(
              context,
              icon: Icons.storage_outlined,
              iconColor: Colors.orange,
              title: 'Storage',
              children: [
                BlocBuilder<ProfileCubit, ProfileState>(
                  builder: (context, profileState) {
                    if (profileState is ProfileLoaded) {
                      final stats = profileState.storageStats;
                      return Column(
                        children: [
                          _buildStorageInfoTile(
                            context,
                            icon: Icons.storage,
                            label: 'Database',
                            value: '${stats.dbSizeMB.toStringAsFixed(2)} MB',
                          ),
                          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.5)),
                          _buildStorageInfoTile(
                            context,
                            icon: Icons.photo_library_outlined,
                            label: 'Media Cache',
                            value: '${stats.mediaSizeMB.toStringAsFixed(2)} MB',
                          ),
                          Divider(height: 1, color: theme.dividerColor.withValues(alpha: 0.5)),
                          _buildStorageInfoTile(
                            context,
                            icon: Icons.folder_outlined,
                            label: 'Total Records',
                            value: '${stats.recordsByTable.values.fold<int>(0, (a, b) => a + b)}',
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: profileState.isClearingCache
                                        ? null
                                        : () => _showClearCacheConfirmation(
                                              context,
                                              'Clear Old Cache',
                                              'This will remove cached data older than 30 days. You can re-sync data from the server later.',
                                              () => context.read<ProfileCubit>().clearOldCache(),
                                            ),
                                    icon: const Icon(Icons.delete_sweep, size: 18),
                                    label: const Text('Clear Cache'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: profileState.isClearingCache
                                        ? null
                                        : () => _showClearCacheConfirmation(
                                              context,
                                              'Clear Media',
                                              'This will remove all downloaded media files. You will need to download them again when needed.',
                                              () => context.read<ProfileCubit>().clearMediaCache(),
                                            ),
                                    icon: const Icon(Icons.image_not_supported_outlined, size: 18),
                                    label: const Text('Clear Media'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    }
                    return _buildStorageInfoTile(
                      context,
                      icon: Icons.storage,
                      label: 'Loading storage info...',
                      value: '',
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // App Info
            Center(
              child: Column(
                children: [
                  Text(
                    'Field Link',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SwitchListTile(
        secondary: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _buildStorageInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _showClearCacheConfirmation(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onConfirm();
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

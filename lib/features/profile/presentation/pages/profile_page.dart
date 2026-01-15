import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../authentication/presentation/bloc/auth/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth/auth_event.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/logout_section.dart';
import '../widgets/notification_preferences_section.dart';
import '../widgets/profile_header.dart';
import '../widgets/storage_management_section.dart';
import '../widgets/sync_status_section.dart';

/// Main profile screen displaying user info, preferences, sync status, and storage management.
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfilePageContent();
  }
}

class _ProfilePageContent extends StatelessWidget {
  const _ProfilePageContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded) {
                return IconButton(
                  icon: state.isRefreshingUser
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : const Icon(Icons.refresh),
                  onPressed: state.isRefreshingUser
                      ? null
                      : () => context.read<ProfileCubit>().refreshUser(),
                  tooltip: 'Refresh profile',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          // Show snackbar for messages
          if (state is ProfileLoaded && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message!),
                duration: const Duration(seconds: 2),
              ),
            );
          }

          // Trigger AuthBloc logout on ProfileLoggedOut state
          if (state is ProfileLoggedOut) {
            // Trigger AuthBloc to update authentication state
            // This will cause AppHome to show the login page
            context.read<AuthBloc>().add(LogoutRequested());
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading profile',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.read<ProfileCubit>().init(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is ProfileLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                await context.read<ProfileCubit>().refreshUser();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // User profile header
                    ProfileHeader(user: state.user),
                    const SizedBox(height: 8),

                    // Notification preferences
                    NotificationPreferencesSection(
                      preferences: state.preferences,
                      onPreferencesChanged: (prefs) {
                        context.read<ProfileCubit>().updatePreferences(prefs);
                      },
                    ),

                    // Sync status
                    SyncStatusSection(
                      syncStatus: state.syncStatus,
                      isSyncing: state.isSyncing,
                      onSyncNow: () {
                        context.read<ProfileCubit>().syncNow();
                      },
                    ),

                    // Storage management
                    StorageManagementSection(
                      storageStats: state.storageStats,
                      isClearing: state.isClearingCache,
                      onClearOldCache: () {
                        context.read<ProfileCubit>().clearOldCache();
                      },
                      onClearMediaCache: () {
                        context.read<ProfileCubit>().clearMediaCache();
                      },
                    ),

                    // Logout
                    LogoutSection(
                      onLogout: () {
                        context.read<ProfileCubit>().logout();
                      },
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

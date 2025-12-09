import 'package:flutter/material.dart';

import '../../domain/entities/user_preferences_entity.dart';
import 'profile_section_card.dart';

/// Widget for managing notification preferences.
class NotificationPreferencesSection extends StatelessWidget {
  final UserPreferencesEntity preferences;
  final Function(UserPreferencesEntity) onPreferencesChanged;

  const NotificationPreferencesSection({
    super.key,
    required this.preferences,
    required this.onPreferencesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ProfileSectionCard(
      title: 'Notifications',
      child: Column(
        children: [
          _buildToggle(
            context,
            title: 'App Notifications',
            subtitle: 'Receive in-app notifications',
            value: preferences.appNotificationsEnabled,
            onChanged: (value) {
              onPreferencesChanged(
                preferences.copyWith(appNotificationsEnabled: value),
              );
            },
          ),
          Divider(color: theme.dividerColor, height: 1),
          _buildToggle(
            context,
            title: 'Email Notifications',
            subtitle: 'Receive email updates',
            value: preferences.emailNotificationsEnabled,
            onChanged: (value) {
              onPreferencesChanged(
                preferences.copyWith(emailNotificationsEnabled: value),
              );
            },
          ),
          Divider(color: theme.dividerColor, height: 1),
          _buildToggle(
            context,
            title: 'Issues',
            subtitle: 'Notifications for issues',
            value: preferences.issuesNotifications,
            onChanged: (value) {
              onPreferencesChanged(
                preferences.copyWith(issuesNotifications: value),
              );
            },
          ),
          Divider(color: theme.dividerColor, height: 1),
          _buildToggle(
            context,
            title: 'Requests',
            subtitle: 'Notifications for requests',
            value: preferences.requestsNotifications,
            onChanged: (value) {
              onPreferencesChanged(
                preferences.copyWith(requestsNotifications: value),
              );
            },
          ),
          Divider(color: theme.dividerColor, height: 1),
          _buildToggle(
            context,
            title: 'Reports',
            subtitle: 'Notifications for reports',
            value: preferences.reportsNotifications,
            onChanged: (value) {
              onPreferencesChanged(
                preferences.copyWith(reportsNotifications: value),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: theme.colorScheme.primary,
    );
  }
}

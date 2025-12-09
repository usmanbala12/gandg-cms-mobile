import 'package:flutter/material.dart';

import '../../domain/entities/user_profile_entity.dart';

/// Header widget displaying user profile information.
class ProfileHeader extends StatelessWidget {
  final UserProfileEntity? user;

  const ProfileHeader({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (user == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar with initials
          CircleAvatar(
            radius: 50,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              user!.avatarInitials,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name
          Text(
            user!.fullName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            user!.email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),

          // Role (if available)
          if (user!.role != null) ...[
            const SizedBox(height: 8),
            Text(
              user!.role!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

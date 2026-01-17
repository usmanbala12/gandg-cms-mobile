import 'dart:ui';
import 'package:field_link/core/presentation/widgets/custom_card.dart';
import 'package:field_link/core/utils/theme/design_system.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/analytics_entity.dart';

/// Renders a single recent activity entry in the dashboard feed.
class RecentActivityTile extends StatelessWidget {
  const RecentActivityTile({super.key, required this.activity});

  final RecentActivityEntry activity;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final timestamp = activity.timestamp != null
        ? DateFormat('MMM d, HH:mm').format(activity.timestamp!.toLocal())
        : 'Unknown time';

    return CustomCard(
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, // Slightly larger
            height: 40,
            decoration: BoxDecoration(
              color: DesignSystem.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DesignSystem.radiusM),
            ),
            alignment: Alignment.center,
            child: Text(
              activity.type.substring(0, 1).toUpperCase(),
              style: theme.textTheme.titleMedium?.copyWith(
                color: DesignSystem.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: DesignSystem.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: DesignSystem.textPrimaryLight, // Should be adaptive based on theme
                  ),
                ),
                if (activity.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    activity.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: DesignSystem.textSecondaryLight,
                    ),
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  timestamp,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: DesignSystem.textSecondaryLight,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

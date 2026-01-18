import 'package:field_link/core/presentation/widgets/custom_card.dart';
import 'package:field_link/core/presentation/widgets/status_badge.dart';
import 'package:field_link/core/utils/theme/design_system.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../domain/entities/issue_entity.dart';

class IssueTile extends StatelessWidget {
  final IssueEntity issue;
  final VoidCallback onTap;

  const IssueTile({super.key, required this.issue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CustomCard(
        onTap: onTap,
        padding: const EdgeInsets.all(DesignSystem.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row: Issue Number & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (issue.issueNumber != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: DesignSystem.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(DesignSystem.radiusS),
                    ),
                    child: Text(
                      '#${issue.issueNumber}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: DesignSystem.primary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                StatusBadge(status: issue.status ?? 'OPEN'),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              issue.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? DesignSystem.textPrimaryDark : DesignSystem.textPrimaryLight,
                fontSize: 17,
              ),
            ),
            
            // Description
            if (issue.description != null && issue.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                issue.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark ? DesignSystem.textSecondaryDark : DesignSystem.textSecondaryLight,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Footer with metadata chips
            Wrap(
              spacing: 12,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                // Priority Chip
                _buildPriorityChip(context, issue.priority),
                
                // Assignee
                if (issue.assignee != null || issue.assigneeId != null)
                  _buildMetaItem(
                    context,
                    icon: Icons.person_outline_rounded,
                    label: issue.assignee != null
                        ? '${issue.assignee!['firstName'] ?? ''}'.trim()
                        : (issue.assigneeId!.length > 8
                            ? '${issue.assigneeId!.substring(0, 8)}...'
                            : issue.assigneeId!),
                  ),
                
                // Relative Date
                _buildMetaItem(
                  context,
                  icon: Icons.access_time_rounded,
                  label: timeago.format(
                    DateTime.fromMillisecondsSinceEpoch(issue.createdAt),
                  ),
                ),
                
                // Sync status indicator
                if (issue.isPending)
                  const _SyncIndicator(icon: Icons.sync, color: DesignSystem.primary)
                else if (issue.hasConflict)
                  const _SyncIndicator(icon: Icons.error_outline_rounded, color: DesignSystem.error),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityChip(BuildContext context, String? priority) {
    final color = _getPriorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getPriorityIcon(priority), size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            (priority ?? 'MEDIUM').toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaItem(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? DesignSystem.textSecondaryDark : DesignSystem.textSecondaryLight;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  IconData _getPriorityIcon(String? priority) {
    switch (priority?.toUpperCase()) {
      case 'CRITICAL':
        return Icons.warning_amber_rounded;
      case 'HIGH':
        return Icons.keyboard_double_arrow_up_rounded;
      case 'MEDIUM':
        return Icons.remove_rounded;
      case 'LOW':
        return Icons.keyboard_arrow_down_rounded;
      default:
        return Icons.remove_rounded;
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toUpperCase()) {
      case 'CRITICAL':
      case 'HIGH':
        return DesignSystem.error;
      case 'MEDIUM':
        return DesignSystem.warning;
      case 'LOW':
        return DesignSystem.success;
      default:
        return DesignSystem.textSecondaryLight;
    }
  }
}

class _SyncIndicator extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SyncIndicator({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 12, color: color),
    );
  }
}

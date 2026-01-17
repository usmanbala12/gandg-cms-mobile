import 'package:field_link/core/presentation/widgets/custom_card.dart';
import 'package:field_link/core/presentation/widgets/status_badge.dart';
import 'package:field_link/core/utils/theme/design_system.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/issue_entity.dart';

class IssueTile extends StatelessWidget {
  final IssueEntity issue;
  final VoidCallback onTap;

  const IssueTile({super.key, required this.issue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CustomCard(
        onTap: onTap,
        padding: const EdgeInsets.all(DesignSystem.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (issue.issueNumber != null)
                        Text(
                          '#${issue.issueNumber}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: DesignSystem.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      Text(
                        issue.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: DesignSystem.textPrimaryLight,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: issue.status ?? 'OPEN'),
              ],
            ),
            const SizedBox(height: 8),
            if (issue.description != null && issue.description!.isNotEmpty) ...[
              Text(
                issue.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: DesignSystem.textSecondaryLight,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
            ],
            const SizedBox(height: 4),
            Row(
              children: [
                _buildPriorityIcon(context, issue.priority),
                const SizedBox(width: 4),
                Text(
                  issue.priority ?? 'MEDIUM',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: DesignSystem.textSecondaryLight,
                  ),
                ),
                const SizedBox(width: 12),
                if (issue.assigneeId != null) ...[
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: DesignSystem.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    issue.assigneeId!.length > 10
                        ? '${issue.assigneeId!.substring(0, 10)}...'
                        : issue.assigneeId!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: DesignSystem.textSecondaryLight,
                    ),
                  ),
                ],
                const Spacer(),
                if (issue.isPending)
                  Icon(Icons.sync, size: 16, color: DesignSystem.primary)
                else if (issue.hasConflict)
                  Icon(
                    Icons.error_outline,
                    size: 16,
                    color: DesignSystem.error,
                  ),
                if (issue.isPending || issue.hasConflict)
                  const SizedBox(width: 4),
                Text(
                  dateFormat.format(
                    DateTime.fromMillisecondsSinceEpoch(issue.createdAt),
                  ),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: DesignSystem.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriorityIcon(BuildContext context, String? priority) {
    IconData icon;
    Color color;

    switch (priority?.toUpperCase()) {
      case 'CRITICAL':
        icon = Icons.priority_high;
        color = DesignSystem.error;
        break;
      case 'HIGH':
        icon = Icons.arrow_upward;
        color = DesignSystem.error;
        break;
      case 'MEDIUM':
        icon = Icons.remove;
        color = DesignSystem.warning;
        break;
      case 'LOW':
        icon = Icons.arrow_downward;
        color = DesignSystem.success;
        break;
      default:
        icon = Icons.remove;
        color = DesignSystem.textSecondaryLight;
    }

    return Icon(icon, size: 16, color: color);
  }
}

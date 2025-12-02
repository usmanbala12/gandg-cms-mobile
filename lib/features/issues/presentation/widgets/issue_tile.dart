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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      issue.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(context, issue.status ?? 'OPEN'),
                ],
              ),
              const SizedBox(height: 8),
              if (issue.description != null &&
                  issue.description!.isNotEmpty) ...[
                Text(
                  issue.description!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildPriorityIcon(context, issue.priority),
                  const SizedBox(width: 4),
                  Text(
                    issue.priority ?? 'MEDIUM',
                    style: theme.textTheme.labelSmall,
                  ),
                  const SizedBox(width: 12),
                  if (issue.assigneeId != null) ...[
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      issue.assigneeId!.length > 10
                          ? '${issue.assigneeId!.substring(0, 10)}...'
                          : issue.assigneeId!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (issue.isPending)
                    Icon(Icons.sync, size: 16, color: theme.colorScheme.primary)
                  else if (issue.hasConflict)
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: theme.colorScheme.error,
                    ),
                  if (issue.isPending || issue.hasConflict)
                    const SizedBox(width: 4),
                  Text(
                    dateFormat.format(
                      DateTime.fromMillisecondsSinceEpoch(issue.createdAt),
                    ),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final theme = Theme.of(context);
    Color color;
    Color onColor;

    switch (status.toUpperCase()) {
      case 'OPEN':
        color = theme.colorScheme.primaryContainer;
        onColor = theme.colorScheme.onPrimaryContainer;
        break;
      case 'IN_PROGRESS':
        color = theme.colorScheme.tertiaryContainer;
        onColor = theme.colorScheme.onTertiaryContainer;
        break;
      case 'RESOLVED':
        color = theme.colorScheme.secondaryContainer;
        onColor = theme.colorScheme.onSecondaryContainer;
        break;
      case 'CLOSED':
        color = theme.colorScheme.surfaceContainerHighest;
        onColor = theme.colorScheme.onSurfaceVariant;
        break;
      default:
        color = theme.colorScheme.surfaceContainerHighest;
        onColor = theme.colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase().replaceAll('_', ' '),
        style: theme.textTheme.labelSmall?.copyWith(
          color: onColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPriorityIcon(BuildContext context, String? priority) {
    final theme = Theme.of(context);
    IconData icon;
    Color color;

    switch (priority?.toUpperCase()) {
      case 'CRITICAL':
        icon = Icons.priority_high;
        color = theme.colorScheme.error;
        break;
      case 'HIGH':
        icon = Icons.arrow_upward;
        color = theme.colorScheme.error;
        break;
      case 'MEDIUM':
        icon = Icons.remove;
        color = theme.colorScheme.primary;
        break;
      case 'LOW':
        icon = Icons.arrow_downward;
        color = theme.colorScheme.secondary;
        break;
      default:
        icon = Icons.remove;
        color = theme.colorScheme.onSurfaceVariant;
    }

    return Icon(icon, size: 16, color: color);
  }
}

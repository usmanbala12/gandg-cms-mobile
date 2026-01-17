import 'package:flutter/material.dart';

import '../../domain/entities/approval_step_entity.dart';

/// A vertical timeline widget displaying approval steps.
class ApprovalTimeline extends StatelessWidget {
  final List<ApprovalStepEntity> steps;
  final int? currentStep;

  const ApprovalTimeline({
    super.key,
    required this.steps,
    this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedSteps = List<ApprovalStepEntity>.from(steps)
      ..sort((a, b) => a.order.compareTo(b.order));

    return Column(
      children: sortedSteps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isLast = index == sortedSteps.length - 1;
        final isCurrent = step.order == currentStep;

        return _buildTimelineStep(
          context,
          step: step,
          isLast: isLast,
          isCurrent: isCurrent,
        );
      }).toList(),
    );
  }

  Widget _buildTimelineStep(
    BuildContext context, {
    required ApprovalStepEntity step,
    required bool isLast,
    required bool isCurrent,
  }) {
    final theme = Theme.of(context);
    final color = _getStepColor(step.status);
    final icon = _getStepIcon(step.status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: isCurrent
                      ? Border.all(color: color, width: 2)
                      : null,
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: step.status == 'APPROVED'
                        ? Colors.green.withValues(alpha: 0.5)
                        : theme.dividerColor,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          // Step content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.approverDisplayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildStatusChip(theme, step.status),
                    ],
                  ),
                  if (step.timestamp != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _formatDateTime(step.timestamp!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                  if (step.comments != null && step.comments!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        step.comments!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                  if (step.delegatedToId != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Delegated${step.delegationReason != null ? ": ${step.delegationReason}" : ""}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, String status) {
    final color = _getStepColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getStepColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'PENDING':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStepIcon(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Icons.check;
      case 'REJECTED':
        return Icons.close;
      case 'PENDING':
        return Icons.hourglass_empty;
      default:
        return Icons.circle_outlined;
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

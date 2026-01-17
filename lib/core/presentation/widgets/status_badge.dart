import 'package:field_link/core/utils/theme/design_system.dart';
import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.color,
  });

  final String status;
  final Color? color;

  Color _getStatusColor(String status) {
    if (color != null) return color!;
    
    switch (status.toUpperCase()) {
      case 'SUBMITTED':
      case 'RESOLVED':
      case 'COMPLETED':
      case 'APPROVED':
        return DesignSystem.success;
      case 'PENDING':
      case 'IN_PROGRESS':
      case 'REVIEW':
        return DesignSystem.warning;
      case 'REJECTED':
      case 'CLOSED':
      case 'ERROR':
        return DesignSystem.error;
      case 'DRAFT':
      case 'OPEN':
        return DesignSystem.info;
      default:
        return DesignSystem.textSecondaryLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(status);
    final theme = Theme.of(context);
    //final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSystem.spacingS,
        vertical: DesignSystem.spacingXS,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DesignSystem.radiusS),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

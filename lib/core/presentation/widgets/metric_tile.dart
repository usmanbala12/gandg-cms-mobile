import 'package:field_link/core/utils/theme/design_system.dart';
import 'package:field_link/core/presentation/widgets/custom_card.dart';
import 'package:flutter/material.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.title,
    required this.value,
    this.icon,
    this.trend,
    this.trendLabel,
    this.iconColor,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData? icon;
  final double? trend; // Positive for up, negative for down
  final String? trendLabel;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = (trend ?? 0) >= 0;

    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(DesignSystem.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (icon != null)
                Container(
                  padding: const EdgeInsets.all(DesignSystem.spacingS),
                  decoration: BoxDecoration(
                    color: (iconColor ?? theme.primaryColor).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignSystem.radiusM),
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: iconColor ?? theme.primaryColor,
                  ),
                ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (isPositive ? DesignSystem.success : DesignSystem.error)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: isPositive ? DesignSystem.success : DesignSystem.error,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${trend!.abs().toStringAsFixed(1)}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isPositive ? DesignSystem.success : DesignSystem.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: DesignSystem.spacingM),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: DesignSystem.textPrimaryLight, 
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: DesignSystem.textSecondaryLight,
            ),
          ),
             if (trendLabel != null) ...[
            const SizedBox(height: DesignSystem.spacingXS),
            Text(
              trendLabel!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: DesignSystem.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:field_link/core/utils/theme/design_system.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.showBorder = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = color ?? (isDark ? DesignSystem.surfaceDark : DesignSystem.surfaceLight);
    final borderColor = isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        border: showBorder ? Border.all(color: borderColor) : null,
        boxShadow: DesignSystem.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(DesignSystem.radiusL),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignSystem.radiusL),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(DesignSystem.spacingM),
            child: child,
          ),
        ),
      ),
    );
  }
}

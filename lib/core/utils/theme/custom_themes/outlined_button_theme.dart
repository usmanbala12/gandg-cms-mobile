import 'package:field_link/core/utils/theme/design_system.dart';
import 'package:flutter/material.dart';

class TOutlinedButtonTheme {
  TOutlinedButtonTheme._();

  static final OutlinedButtonThemeData lightOutlinedButtonTheme =
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: DesignSystem.primary,
          side: const BorderSide(color: DesignSystem.primary),
          textStyle: const TextStyle(
            fontSize: 16,
            color: DesignSystem.primary,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          ),
        ),
      );

  static final OutlinedButtonThemeData darkOutlinedButtonTheme =
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: Colors.white,
          side: const BorderSide(color: DesignSystem.primary),
          textStyle: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          ),
        ),
      );
}

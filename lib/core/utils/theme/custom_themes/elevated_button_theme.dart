import 'package:field_link/core/utils/theme/design_system.dart';
import 'package:flutter/material.dart';

class TElevatedButtonTheme {
  TElevatedButtonTheme._();

  static final ElevatedButtonThemeData lightElevatedButtonStyle =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: DesignSystem.onPrimary,
      backgroundColor: DesignSystem.primary,
      disabledBackgroundColor: Colors.grey,
      disabledForegroundColor: Colors.grey,
      side: const BorderSide(color: DesignSystem.primary),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      textStyle: const TextStyle(
        fontSize: 16,
        color: DesignSystem.onPrimary,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
      ),
    ),
  );

  static final ElevatedButtonThemeData darkElevatedButtonStyle =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: DesignSystem.onPrimary,
      backgroundColor: DesignSystem.primary,
      disabledBackgroundColor: Colors.grey,
      disabledForegroundColor: Colors.grey,
      side: const BorderSide(color: DesignSystem.primary),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      textStyle: const TextStyle(
        fontSize: 16,
        color: DesignSystem.onPrimary,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
      ),
    ),
  );
}

import 'package:field_link/core/utils/theme/design_system.dart';
import 'package:flutter/material.dart';

class TChipTheme {
  TChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: Colors.grey.withValues(alpha: 0.4),
    labelStyle: const TextStyle(color: Colors.black),
    selectedColor: DesignSystem.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    checkmarkColor: DesignSystem.onPrimary,
  );

  static ChipThemeData darkChipTheme = ChipThemeData(
    disabledColor: Colors.grey.withValues(alpha: 0.4),
    labelStyle: const TextStyle(color: Colors.white),
    selectedColor: DesignSystem.primary,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    checkmarkColor: DesignSystem.onPrimary,
  );
}

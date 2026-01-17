import 'package:field_link/core/utils/theme/design_system.dart';
import 'package:flutter/material.dart';

class TTextFormFieldTheme {
  TTextFormFieldTheme._();

  static InputDecorationTheme lightTextFieldTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: DesignSystem.textSecondaryLight,
    suffixIconColor: DesignSystem.textSecondaryLight,
    labelStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: DesignSystem.textPrimaryLight,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: DesignSystem.textSecondaryLight,
    ),
    errorStyle: const TextStyle().copyWith(
      fontStyle: FontStyle.normal,
      color: DesignSystem.error,
      fontSize: 12,
    ),
    floatingLabelStyle: const TextStyle().copyWith(
      color: DesignSystem.textPrimaryLight,
      fontWeight: FontWeight.w600,
    ),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(DesignSystem.radiusS),
      borderSide: const BorderSide(color: Color(0xFFE5E5EA), width: 1),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(DesignSystem.radiusS),
      borderSide: const BorderSide(color: DesignSystem.primary, width: 2),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(DesignSystem.radiusS),
      borderSide: const BorderSide(color: Color(0xFFE5E5EA), width: 1),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(DesignSystem.radiusS),
      borderSide: const BorderSide(color: DesignSystem.error, width: 1),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(DesignSystem.radiusS),
      borderSide: const BorderSide(color: DesignSystem.error, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );

  static InputDecorationTheme darkTextFieldTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: DesignSystem.textSecondaryDark,
    suffixIconColor: DesignSystem.textSecondaryDark,
    labelStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: DesignSystem.textPrimaryDark,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: const TextStyle().copyWith(
      fontSize: 14,
      color: DesignSystem.textSecondaryDark,
    ),
    errorStyle: const TextStyle().copyWith(
      fontStyle: FontStyle.normal,
      color: DesignSystem.error,
      fontSize: 12,
    ),
    floatingLabelStyle: const TextStyle().copyWith(
      color: DesignSystem.textPrimaryDark,
      fontWeight: FontWeight.w600,
    ),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(DesignSystem.radiusS),
      borderSide: const BorderSide(color: Color(0xFF38383A), width: 1),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(DesignSystem.radiusS),
      borderSide: const BorderSide(color: DesignSystem.primary, width: 2),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(DesignSystem.radiusS),
      borderSide: const BorderSide(color: Color(0xFF38383A), width: 1),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(DesignSystem.radiusS),
      borderSide: const BorderSide(color: DesignSystem.error, width: 1),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(DesignSystem.radiusS),
      borderSide: const BorderSide(color: DesignSystem.error, width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}

import 'package:field_link/core/utils/theme/design_system.dart';
import 'package:field_link/core/utils/theme/custom_themes/appbar_theme.dart';
import 'package:field_link/core/utils/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:field_link/core/utils/theme/custom_themes/checkbox_theme.dart';
import 'package:field_link/core/utils/theme/custom_themes/chip_theme.dart';
import 'package:field_link/core/utils/theme/custom_themes/elevated_button_theme.dart';
import 'package:field_link/core/utils/theme/custom_themes/outlined_button_theme.dart';
import 'package:field_link/core/utils/theme/custom_themes/text_field_theme.dart';
import 'package:field_link/core/utils/theme/custom_themes/text_theme.dart';
import 'package:flutter/material.dart';

class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter',
    brightness: Brightness.light,
    primaryColor: DesignSystem.primary,
    scaffoldBackgroundColor: DesignSystem.backgroundLight,
    dividerColor: const Color(0xFFE5E5EA), // Light gray divider
    textTheme: TTextTheme.lightTextThem,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonStyle,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    bottomSheetTheme: TBottomSheetTheme.lightBottomSheetTheme,
    checkboxTheme: TCheckboxTheme.lightCheckboxTheme,
    chipTheme: TChipTheme.lightChipTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.lightTextFieldTheme,
    colorScheme: const ColorScheme.light(
      primary: DesignSystem.primary,
      onPrimary: DesignSystem.onPrimary,
      secondary: DesignSystem.secondary,
      onSecondary: DesignSystem.onSecondary,
      surface: DesignSystem.surfaceLight,
      onSurface: DesignSystem.textPrimaryLight,
      error: DesignSystem.error,
      onError: Colors.white,
      outline: DesignSystem.textSecondaryLight,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Inter', // Applied globally
    brightness: Brightness.dark,
    primaryColor: DesignSystem.primary,
    scaffoldBackgroundColor: DesignSystem.backgroundDark,
    dividerColor: const Color(0xFF38383A), // Dark divider
    textTheme: TTextTheme.darkTextTheme,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonStyle,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    bottomSheetTheme: TBottomSheetTheme.darkBottomSheetTheme,
    checkboxTheme: TCheckboxTheme.darkCheckboxTheme,
    chipTheme: TChipTheme.darkChipTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.darkTextFieldTheme,
    colorScheme: const ColorScheme.dark(
      primary: DesignSystem.primary,
      onPrimary: DesignSystem.onPrimary,
      secondary: DesignSystem.secondary,
      onSecondary: DesignSystem.onSecondary,
      surface: DesignSystem.surfaceDark,
      onSurface: DesignSystem.textPrimaryDark,
      error: DesignSystem.error,
      onError: Colors.black,
      outline: DesignSystem.textSecondaryDark,
    ),
  );
}

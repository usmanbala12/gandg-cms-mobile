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

  // Minimal light theme: white background, black text, no gradients
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    brightness: Brightness.light,
    primaryColor: Colors.black,
    scaffoldBackgroundColor: Colors.white,
    dividerColor: const Color(0xFFE0E0E0),
    textTheme: TTextTheme.lightTextThem,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonStyle,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    bottomSheetTheme: TBottomSheetTheme.lightBottomSheetTheme,
    checkboxTheme: TCheckboxTheme.lightCheckboxTheme,
    chipTheme: TChipTheme.lightChipTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.lightOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.lightTextFieldTheme,
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      onPrimary: Colors.white,
      secondary: Colors.black87,
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
    ),
  );

  // Minimal dark theme: black background, white text, no gradients
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Roboto',
    brightness: Brightness.dark,
    primaryColor: Colors.white,
    scaffoldBackgroundColor: Colors.black,
    dividerColor: const Color(0xFF303030),
    textTheme: TTextTheme.darkTextTheme,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonStyle,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    bottomSheetTheme: TBottomSheetTheme.darkBottomSheetTheme,
    checkboxTheme: TCheckboxTheme.darkCheckboxTheme,
    chipTheme: TChipTheme.darkChipTheme,
    outlinedButtonTheme: TOutlinedButtonTheme.darkOutlinedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.darkTextFieldTheme,
    colorScheme: const ColorScheme.dark(
      primary: Colors.white,
      onPrimary: Colors.black,
      secondary: Colors.white70,
      onSecondary: Colors.black,
      surface: Colors.black,
      onSurface: Colors.white,
      error: Colors.red,
      onError: Colors.black,
    ),
  );
}

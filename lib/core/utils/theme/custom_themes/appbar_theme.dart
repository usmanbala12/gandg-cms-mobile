import 'package:field_link/core/utils/theme/design_system.dart';
import 'package:flutter/material.dart';

class TAppBarTheme {
  TAppBarTheme._();

  static const AppBarTheme lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: DesignSystem.textPrimaryLight, size: 24),
    actionsIconTheme: IconThemeData(color: DesignSystem.textPrimaryLight, size: 24),
    titleTextStyle: TextStyle(
      color: DesignSystem.textPrimaryLight,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      fontFamily: 'Inter',
    ),
  );

  static const AppBarTheme darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: DesignSystem.textPrimaryDark, size: 24),
    actionsIconTheme: IconThemeData(color: DesignSystem.textPrimaryDark, size: 24),
    titleTextStyle: TextStyle(
      color: DesignSystem.textPrimaryDark,
      fontSize: 18,
      fontWeight: FontWeight.w600,
      fontFamily: 'Inter',
    ),
  );
}

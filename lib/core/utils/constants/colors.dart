import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  //App Basic Color
  //static const Color primary = Color(0xFF4b68ff);
  static const Color secondary = Color(0xFFFFE24B);
  static const Color accent = Color(0xFFb0c7ff);

  //Gradient Color
  static const Gradient linearGradient = LinearGradient(colors: []);

  // Text Color
  static const Color textprimary = Color(0xFF333333);
  static const Color textsecondary = Color(0xFF6c757D);
  static const Color textWhite = Colors.white;

  // Background Color
  static const Color light = Color(0xFFF6F6f6);
  static const Color dark = Color(0xFF272727);
  static const Color primaryBackground = Color(0xFFf3f5ff);

  // Background Container Color
  static const Color lightContainer = Color(0xFFf6f6f6);
  static Color darkContainer = AppColors.textWhite.withOpacity(0.1);

  // Button Color
  static const Color buttonPrimary = Color(0xFF4b68ff);
  static const Color buttonSecondary = Color(0xFF6c757D);
  static const Color buttonDisabled = Color(0xFFc4c4c4);

  // Border Color
  static const Color borderPrimary = Color(0xFFd9d9d9);
  static const Color borderSecondary = Color(0xFFe6e6e6);

  // Erro and Validaton colors
  static const Color error = Color(0xFFd32f2f);
  static const Color success = Color(0xFF388e3c);
  static const Color warning = Color(0xFFf57c00);
  static const Color info = Color(0xFF1976d2);

  static const Color black = Color.fromARGB(0, 0, 0, 0);
  static const Color darkerGrey = Color(0xFF4f4f4f);
  static const Color darkGrey = Color(0xFF939393);
  static const Color darkcontainer = Color(0xFF4f4f4f);
  static const Color grey = Color(0xFFe0e0e0);
  static const Color softGrey = Color(0xFFf4f4f4);
  static const Color lightGrey = Color(0xFFf9f9f9);
  //static const Color white = Color(0xFFFFFFFF);

  static const Color primary = Color(0xFF037EFF);
  static const Color background = Color(0xFFF9FAFB);
  static const Color white = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1C1C1C);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color alert = Color(0xFFFF3B30);
  //static const Color success = Color(0xFF10B981);
  //static const Color warning = Color(0xFFF59E0B);

  // Status colors
  static const Color inStockBg = Color(0xFFD1FAE5);
  static const Color inStockText = Color(0xFF065F46);
  static const Color lowStockBg = Color(0xFFFEF3C7);
  static const Color lowStockText = Color(0xFF92400E);
  static const Color outStockBg = Color(0xFFFEE2E2);
  static const Color outStockText = Color(0xFF991B1B);
}

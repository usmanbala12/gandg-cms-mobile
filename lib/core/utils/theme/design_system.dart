import 'package:flutter/material.dart';

class DesignSystem {
  DesignSystem._();

  // -- Brand Colors --
  static const Color primary = Color(0xFF5E5CE6); // Deep Indigo
  static const Color onPrimary = Colors.white;
  
  static const Color secondary = Color(0xFF32D74B); // Vibrant Green (Success/Action)
  static const Color onSecondary = Colors.white;
  
  static const Color tertiary = Color(0xFFFF9F0A); // Warm Orange (Warning/Attention)

  // -- Background/Surface Colors --
  static const Color backgroundLight = Color(0xFFF8F9FA); // Soft off-white
  static const Color surfaceLight = Colors.white;
  
  static const Color backgroundDark = Color(0xFF121212); // Deep dark
  static const Color surfaceDark = Color(0xFF1E1E1E); // Lighter dark for cards

  // -- Text Colors --
  static const Color textPrimaryLight = Color(0xFF1C1C1E); // Almost black
  static const Color textSecondaryLight = Color(0xFF8E8E93); // iOS-like gray
  
  static const Color textPrimaryDark = Color(0xFFF2F2F7);
  static const Color textSecondaryDark = Color(0xFFAEAEB2);

  // -- Status Colors --
  static const Color success = Color(0xFF34C759);
  static const Color error = Color(0xFFFF453A);
  static const Color warning = Color(0xFFFF9F0A);
  static const Color info = Color(0xFF0A84FF);

  // -- Shadows --
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // -- Spacing & Dimensions --
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 24.0;
}

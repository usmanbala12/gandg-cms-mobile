import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:field_link/core/utils/theme/design_system.dart';

class TTextTheme {
  TTextTheme._();

  static TextTheme lightTextThem = TextTheme(
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: DesignSystem.textPrimaryLight,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: DesignSystem.textPrimaryLight,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: DesignSystem.textPrimaryLight,
    ),

    titleLarge: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: DesignSystem.textPrimaryLight,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: DesignSystem.textPrimaryLight,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: DesignSystem.textPrimaryLight,
    ),

    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: DesignSystem.textPrimaryLight,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: DesignSystem.textPrimaryLight,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: DesignSystem.textSecondaryLight,
    ),

    labelLarge: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: DesignSystem.textPrimaryLight,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: DesignSystem.textSecondaryLight,
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: DesignSystem.textPrimaryDark,
    ),
    headlineMedium: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: DesignSystem.textPrimaryDark,
    ),
    headlineSmall: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: DesignSystem.textPrimaryDark,
    ),

    titleLarge: GoogleFonts.poppins(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: DesignSystem.textPrimaryDark,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: DesignSystem.textPrimaryDark,
    ),
    titleSmall: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: DesignSystem.textPrimaryDark,
    ),

    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: DesignSystem.textPrimaryDark,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: DesignSystem.textPrimaryDark,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: DesignSystem.textSecondaryDark,
    ),

    labelLarge: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: DesignSystem.textPrimaryDark,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: DesignSystem.textSecondaryDark,
    ),
  );
}

import 'package:flutter/material.dart';

/// Standardized text color hierarchy for consistent UI across the app
/// Use these methods instead of directly accessing AppColors for text
class TextHierarchy {
  TextHierarchy._();

  // ============ LIGHT MODE TEXT COLORS ============

  /// Primary text - Main headings, titles, important content
  /// Usage: Page titles, card titles, primary labels
  static const Color lightPrimary = Color(0xFF1C1C1C);

  /// Secondary text - Supporting text, descriptions, metadata
  /// Usage: Subtitles, descriptions, helper text
  static const Color lightSecondary = Color(0xFF6B7280);

  /// Tertiary text - Less important text, timestamps, hints
  /// Usage: Timestamps, hints, placeholder text
  static const Color lightTertiary = Color(0xFF9CA3AF);

  /// Disabled text - Inactive or disabled elements
  /// Usage: Disabled buttons, inactive items
  static const Color lightDisabled = Color(0xFFD1D5DB);

  // ============ DARK MODE TEXT COLORS ============

  /// Primary text - Main headings, titles, important content
  static const Color darkPrimary = Color(0xFFFFFFFF);

  /// Secondary text - Supporting text, descriptions, metadata
  static const Color darkSecondary = Color(0xFFE5E7EB);

  /// Tertiary text - Less important text, timestamps, hints
  static const Color darkTertiary = Color(0xFF9CA3AF);

  /// Disabled text - Inactive or disabled elements
  static const Color darkDisabled = Color(0xFF6B7280);

  // ============ HELPER METHODS ============

  /// Get primary text color based on theme
  static Color primary(bool isDark) => isDark ? darkPrimary : lightPrimary;

  /// Get secondary text color based on theme
  static Color secondary(bool isDark) =>
      isDark ? darkSecondary : lightSecondary;

  /// Get tertiary text color based on theme
  static Color tertiary(bool isDark) => isDark ? darkTertiary : lightTertiary;

  /// Get disabled text color based on theme
  static Color disabled(bool isDark) => isDark ? darkDisabled : lightDisabled;

  // ============ TEXT STYLES ============

  /// Heading 1 - Large page titles
  static TextStyle h1(bool isDark) => TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primary(isDark),
      );

  /// Heading 2 - Section titles
  static TextStyle h2(bool isDark) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primary(isDark),
      );

  /// Heading 3 - Card titles, subsection titles
  static TextStyle h3(bool isDark) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primary(isDark),
      );

  /// Heading 4 - Small titles
  static TextStyle h4(bool isDark) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary(isDark),
      );

  /// Body Large - Main content text
  static TextStyle bodyLarge(bool isDark) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primary(isDark),
      );

  /// Body Medium - Standard body text
  static TextStyle bodyMedium(bool isDark) => TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: primary(isDark),
      );

  /// Body Small - Smaller body text
  static TextStyle bodySmall(bool isDark) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondary(isDark),
      );

  /// Caption - Small supporting text
  static TextStyle caption(bool isDark) => TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: secondary(isDark),
      );

  /// Label - Small labels, metadata
  static TextStyle label(bool isDark) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: tertiary(isDark),
      );

  /// Tiny - Very small text, timestamps
  static TextStyle tiny(bool isDark) => TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: tertiary(isDark),
      );
}

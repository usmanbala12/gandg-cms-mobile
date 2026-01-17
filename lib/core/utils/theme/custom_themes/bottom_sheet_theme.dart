import 'package:field_link/core/utils/theme/design_system.dart';
import 'package:flutter/material.dart';

class TBottomSheetTheme {
  TBottomSheetTheme._();

  static const BottomSheetThemeData lightBottomSheetTheme =
      BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: DesignSystem.surfaceLight,
        modalBackgroundColor: DesignSystem.surfaceLight,
        constraints: BoxConstraints(minWidth: double.infinity),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(DesignSystem.radiusXL)),
        ),
      );

  static const BottomSheetThemeData darkBottomSheetTheme = BottomSheetThemeData(
    showDragHandle: true,
    backgroundColor: DesignSystem.surfaceDark,
    modalBackgroundColor: DesignSystem.surfaceDark,
    constraints: BoxConstraints(minWidth: double.infinity),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(DesignSystem.radiusXL)),
    ),
  );
}

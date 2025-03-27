import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

final class AppThemes {
  const AppThemes._();

  static ThemeData light = ThemeData(
    brightness: Brightness.light,
    fontFamily: AppFonts.mulish.fontFamily,
    extensions: const <ThemeExtension<AppColorsTheme>>[
      LightColorsTheme(),
    ],
  );

  static ThemeData dark = ThemeData(
    brightness: Brightness.dark,
    fontFamily: AppFonts.mulish.fontFamily,
    extensions: const <ThemeExtension<AppColorsTheme>>[
      DarkColorsTheme(),
    ],
  );
}

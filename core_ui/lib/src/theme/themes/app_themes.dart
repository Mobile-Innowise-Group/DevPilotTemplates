import 'package:flutter/material.dart';

import '../../../core_ui.dart';

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

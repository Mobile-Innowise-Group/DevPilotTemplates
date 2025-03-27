import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

abstract class AppColorsTheme extends ThemeExtension<AppColorsTheme> {
  const AppColorsTheme();

  Color get text;

  @override
  ThemeExtension<AppColorsTheme> copyWith() {
    throw UnimplementedError();
  }

  @override
  ThemeExtension<AppColorsTheme> lerp(covariant ThemeExtension<AppColorsTheme>? other, double t) {
    throw UnimplementedError();
  }
}

class LightColorsTheme extends AppColorsTheme {
  const LightColorsTheme();

  @override
  Color get text => AppColors.black;
}

class DarkColorsTheme extends LightColorsTheme {
  const DarkColorsTheme();
}

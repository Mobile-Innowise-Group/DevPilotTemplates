import 'package:flutter/material.dart';

import '../colors/app_colors_theme.dart';

extension ColorsContextExtension on ThemeData {
  AppColorsTheme get colors {
    return extension<AppColorsTheme>()!;
  }
}

extension ThemeDataExtension on BuildContext {
  ThemeData get theme {
    return Theme.of(this);
  }
}

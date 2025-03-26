import 'package:flutter/material.dart';

import '../../../core_ui.dart';

final class AppFonts {
  const AppFonts._();

  static const String _mulishFontFamily = 'Mulish';

  static const TextStyle mulish = TextStyle(
    fontFamily: _mulishFontFamily,
    package: kCoreUiPackageName,
  );
}

import 'package:flutter/material.dart';
import 'package:mindly/shared/design_tokens/mindly_colors.dart';

abstract final class MindlyTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: MindlyColors.lavender,
      brightness: Brightness.light,
      surface: MindlyColors.canvas,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: MindlyColors.canvas,
      cardTheme: const CardThemeData(elevation: 0, margin: EdgeInsets.zero),
    );
  }
}

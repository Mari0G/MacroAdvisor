import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData light() => _theme(Brightness.light);

  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
    );
  }
}

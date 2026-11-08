import 'package:flutter/material.dart';

/// Saha yeşili tohum renginden üretilen açık ve koyu temalar.
abstract final class AppTheme {
  static const Color _pitchGreen = Color(0xFF1B8A3C);

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _pitchGreen,
        brightness: brightness,
      ),
    );
  }
}

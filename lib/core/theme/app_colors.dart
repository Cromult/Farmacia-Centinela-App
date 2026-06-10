import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors Base
  static const Color primary = Color(0xFF00327D); // Cobalt Blue
  static const Color onPrimary = Color(0xFFFFFFFF);
  
  static const Color secondary = Color(0xFF006E2D); // Forest Green
  static const Color onSecondary = Color(0xFFFFFFFF);
  
  static const Color tertiary = Color(0xFF750001); // Deep Red
  static const Color onTertiary = Color(0xFFFFFFFF);
  
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  
  static const Color background = Color(0xFFF9F9FF);
  static const Color onBackground = Color(0xFF141B2C); // Ink Black
  
  static const Color surface = Color(0xFFF9F9FF);
  static const Color onSurface = Color(0xFF141B2C);
  
  static const Color outline = Color(0xFF737784);

  // Esquema de colores para inyectar en ThemeData
  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: onPrimary,
    secondary: secondary,
    onSecondary: onSecondary,
    tertiary: tertiary,
    onTertiary: onTertiary,
    error: error,
    onError: onError,
    surface: surface,
    onSurface: onSurface,
    outline: outline,
  );
}
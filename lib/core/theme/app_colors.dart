import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Brand
  static const primary = Color(0xFF3157D5);
  static const primaryDark = Color(0xFF1B2F8F);
  static const primaryLight = Color(0xFF8FA8FF);
  static const secondary = Color(0xFF0FA3A3);

  // Semantic
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFDC2626);
  static const info = Color(0xFF0284C7);

  // Light
  static const lightBackground = Color(0xFFF5F6FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightBorder = Color(0xFFE4E7EF);
  static const lightTextPrimary = Color(0xFF111827);
  static const lightTextSecondary = Color(0xFF6B7280);

  // Dark
  static const darkBackground = Color(0xFF0E1120);
  static const darkSurface = Color(0xFF171A2C);
  static const darkBorder = Color(0xFF2A2E45);

    static const accent = Color(0xFF7C5CE6);

  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary, Color(0xFF2B7FD8)],
  );
}
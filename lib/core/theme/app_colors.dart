import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  static const Color secondary = Color(0xFF03DAC6);
  static const Color secondaryDark = Color(0xFF018786);
  static const Color secondaryLight = Color(0xFF66FFF9);

  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);

  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onBackground = Color(0xFF000000);
  static const Color onSurface = Color(0xFF000000);
  static const Color onError = Color(0xFFFFFFFF);

  // Additional colors for the app
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Gradient colors
  static const List<Color> primaryGradient = [primary, primaryDark];
  static const List<Color> successGradient = [success, Color(0xFF388E3C)];
  static const List<Color> warningGradient = [warning, Color(0xFFF57C00)];
  static const List<Color> errorGradient = [error, Color(0xFF8E0000)];
}

import 'package:flutter/material.dart';

class AppColors {
  // Primary (Gradient Start/End concept, but mapped to solid colors for Theme)
  static const Color primary = Color(0xFFD5006D); // Vibrant Pink/Red (Gradient Start-ish)
  static const Color primaryVariant = Color(0xFF6A1B9A); // Deep Purple (Gradient End)
  
  // Gradient Colors (Publicly accessible for custom widgets)
  static const Color gradientStart = Color(0xFFFF2B68); // Bright Red-Pink
  static const Color gradientEnd = Color(0xFF651FFF); // Deep Purple Accent

  // Secondary
  static const Color secondary = Color(0xFFFFD600); // Yellow Accent (Good contrast with Purple)
  static const Color secondaryVariant = Color(0xFFFF6D00); // Orange

  // Light Theme
  static const Color lightBackground = Color(0xFFF3E5F5); // Very light purple tint
  static const Color lightSurface = Colors.white;
  static const Color lightOnBackground = Color(0xFF212121);
  static const Color lightOnSurface = Color(0xFF212121);

  // Dark Theme
  static const Color darkBackground = Color(0xFF120024); // Very dark purple
  static const Color darkSurface = Color(0xFF1E0038); // Dark purple surface
  static const Color darkOnBackground = Color(0xFFEDE7F6);
  static const Color darkOnSurface = Color(0xFFEDE7F6);

  // Status
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFFFA000);
}

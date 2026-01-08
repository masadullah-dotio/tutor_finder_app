import 'package:flutter/material.dart';

class AppColors {
  // Primary (Red/Purple mix)
  static const Color primary = Color(0xFFE53935); // Red 600
  static const Color primaryVariant = Color(0xFFB71C1C); // Red 900
  static const Color secondary = Color(0xFF8E24AA); // Purple 600
  static const Color secondaryVariant = Color(0xFF4A148C); // Purple 900

  // Light Theme
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Color(0xFFF5F5F5); // Grey 100
  static const Color lightOnBackground = Colors.black;
  static const Color lightOnSurface = Colors.black;

  // Dark Theme
  static const Color darkBackground = Colors.black;
  static const Color darkSurface = Color(0xFF1E1E1E); // Grey 900
  static const Color darkOnBackground = Colors.white;
  static const Color darkOnSurface = Colors.white;

  // Status
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50); // Green 500
  static const Color warning = Color(0xFFFFC107); // Amber 500
}

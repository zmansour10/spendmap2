import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2E7D32); // Green
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF4CAF50);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF1976D2); // Blue
  static const Color secondaryDark = Color(0xFF0D47A1);
  static const Color secondaryLight = Color(0xFF42A5F5);
  
  // Accent Colors
  static const Color accent = Color(0xFFFF6F00); // Orange
  static const Color accentLight = Color(0xFFFFB74D);
  
  // Neutral Colors - Light Theme
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  
  // Neutral Colors - Dark Theme
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2D2D2D);
  
  // Text Colors - Light Theme
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textDisabledLight = Color(0xFFBDBDBD);
  
  // Text Colors - Dark Theme
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textDisabledDark = Color(0xFF616161);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  
  // Category Colors (for expense categories)
  static const List<Color> categoryColors = [
    Color(0xFFE57373), // Red
    Color(0xFFBA68C8), // Purple
    Color(0xFF64B5F6), // Blue
    Color(0xFF4DB6AC), // Teal
    Color(0xFF81C784), // Green
    Color(0xFFAED581), // Light Green
    Color(0xFFFFB74D), // Orange
    Color(0xFFFF8A65), // Deep Orange
    Color(0xFFA1887F), // Brown
    Color(0xFF90A4AE), // Blue Grey
    Color(0xFFF06292), // Pink
    Color(0xFF7986CB), // Indigo
  ];
  
  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF1976D2),
    Color(0xFF388E3C),
    Color(0xFFE64A19),
    Color(0xFF7B1FA2),
    Color(0xFF455A64),
    Color(0xFFE91E63),
    Color(0xFF00ACC1),
    Color(0xFFFB8C00),
  ];
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);
  
  // Shadow Colors
  static const Color shadowLight = Color(0x1F000000);
  static const Color shadowDark = Color(0x3F000000);
  
  // Helper method to get color by index (useful for categories)
  static Color getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }
  
  static Color getChartColor(int index) {
    return chartColors[index % chartColors.length];
  }
}
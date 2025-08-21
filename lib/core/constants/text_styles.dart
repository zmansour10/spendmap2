import 'package:flutter/material.dart';

class AppTextStyles {
  // Font Family
  static const String fontFamily = 'System'; // Uses system font
  
  // Base Text Styles
  static const TextStyle _baseStyle = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.normal,
    letterSpacing: 0.0,
  );
  
  // Headings
  static final TextStyle h1 = _baseStyle.copyWith(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  static final TextStyle h2 = _baseStyle.copyWith(
    fontSize: 28.0,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );
  
  static final TextStyle h3 = _baseStyle.copyWith(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static final TextStyle h4 = _baseStyle.copyWith(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );
  
  static final TextStyle h5 = _baseStyle.copyWith(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  static final TextStyle h6 = _baseStyle.copyWith(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  // Body Text
  static final TextStyle bodyLarge = _baseStyle.copyWith(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static final TextStyle bodyMedium = _baseStyle.copyWith(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
  
  static final TextStyle bodySmall = _baseStyle.copyWith(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
  
  // Labels
  static final TextStyle labelLarge = _baseStyle.copyWith(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );
  
  static final TextStyle labelMedium = _baseStyle.copyWith(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  
  static final TextStyle labelSmall = _baseStyle.copyWith(
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  
  // Special Text Styles
  static final TextStyle caption = _baseStyle.copyWith(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    height: 1.3,
  );
  
  static final TextStyle overline = _baseStyle.copyWith(
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
    height: 1.6,
    letterSpacing: 1.5,
  );
  
  // Button Text Styles
  static final TextStyle buttonLarge = _baseStyle.copyWith(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  static final TextStyle buttonMedium = _baseStyle.copyWith(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  static final TextStyle buttonSmall = _baseStyle.copyWith(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  // Currency/Number Text Styles
  static final TextStyle currencyLarge = _baseStyle.copyWith(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  
  static final TextStyle currencyMedium = _baseStyle.copyWith(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  
  static final TextStyle currencySmall = _baseStyle.copyWith(
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
    height: 1.2,
    fontFeatures: [FontFeature.tabularFigures()],
  );
  
  // Error Text Style
  static final TextStyle error = _baseStyle.copyWith(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    height: 1.3,
  );
}
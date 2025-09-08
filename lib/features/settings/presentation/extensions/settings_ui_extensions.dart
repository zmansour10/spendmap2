import 'package:flutter/material.dart';
import '../../domain/entities/settings_entity.dart';

/// Extensions to convert between domain objects and Flutter UI objects
/// This belongs to the presentation layer, so it can import material.dart

extension AppThemeModeExtension on AppThemeMode {
  /// Convert to Flutter ThemeMode
  ThemeMode toFlutterThemeMode() {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Create from Flutter ThemeMode
  static AppThemeMode fromFlutterThemeMode(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
      case ThemeMode.system:
        return AppThemeMode.system;
    }
  }
}

extension ThemeModeExtension on ThemeMode {
  /// Convert to domain AppThemeMode
  AppThemeMode toAppThemeMode() {
    return AppThemeModeExtension.fromFlutterThemeMode(this);
  }
}

extension AppTimeOfDayExtension on AppTimeOfDay {
  /// Convert to Flutter TimeOfDay
  TimeOfDay toFlutterTimeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Create from Flutter TimeOfDay
  static AppTimeOfDay fromFlutterTimeOfDay(TimeOfDay timeOfDay) {
    return AppTimeOfDay(hour: timeOfDay.hour, minute: timeOfDay.minute);
  }
}

extension TimeOfDayExtension on TimeOfDay {
  /// Convert to domain AppTimeOfDay
  AppTimeOfDay toAppTimeOfDay() {
    return AppTimeOfDayExtension.fromFlutterTimeOfDay(this);
  }
}
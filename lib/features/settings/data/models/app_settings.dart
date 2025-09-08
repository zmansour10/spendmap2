import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/settings_entity.dart';

part 'app_settings.freezed.dart';
part 'app_settings.g.dart';

/// Data model for app settings with JSON serialization
@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    // App Preferences
    @Default('USD') String currency,
    @Default('en') String language,
    @Default('system') String themeMode,
    int? defaultCategoryId,
    
    // Display Settings
    @Default(true) bool showCentsInAmounts,
    @Default(false) bool useCompactExpenseView,
    @Default(true) bool showExpenseCategories,
    @Default('MM/dd/yyyy') String dateFormat,
    @Default('12h') String timeFormat,
    
    // Notification Settings
    @Default(true) bool enableNotifications,
    @Default(false) bool dailySpendingReminders,
    @Default(true) bool budgetAlerts,
    @Default(false) bool weeklyReports,
    String? dailyReminderTime, 
    
    // Privacy & Security
    @Default(false) bool requireBiometrics,
    @Default(false) bool hideAmountsInRecents,
    @Default(true) bool enableAnalytics,
    @Default(true) bool enableCrashReporting,
    
    // Data & Backup
    @Default(true) bool autoBackup,
    @Default(7) int backupFrequencyDays,
    @Default(false) bool syncEnabled,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'last_backup_date') String? lastBackupDate, // ISO string
    
    // Advanced Settings
    @Default(365) int expenseHistoryDays,
    @Default(false) bool enableDebugMode,
    @Default('json') String exportFormat,
    @Default(true) bool confirmBeforeDelete,
    
    // App State
    @Default(true) bool isFirstLaunch,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'onboarding_completed_at') String? onboardingCompletedAt, // ISO string
    @Default('1.0.0') String appVersion,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'created_at') required String createdAt, // ISO string
    // ignore: invalid_annotation_target
    @JsonKey(name: 'updated_at') required String updatedAt, // ISO string
  }) = _AppSettings;

  /// Create from JSON
  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

  /// Create from SharedPreferences map
  factory AppSettings.fromPreferences(Map<String, dynamic> prefs) {
    return AppSettings(
      // App Preferences
      currency: prefs['currency'] as String? ?? 'USD',
      language: prefs['language'] as String? ?? 'en',
      themeMode: prefs['theme_mode'] as String? ?? 'system',
      defaultCategoryId: prefs['default_category_id'] as int?,
      
      // Display Settings
      showCentsInAmounts: prefs['show_cents_in_amounts'] as bool? ?? true,
      useCompactExpenseView: prefs['use_compact_expense_view'] as bool? ?? false,
      showExpenseCategories: prefs['show_expense_categories'] as bool? ?? true,
      dateFormat: prefs['date_format'] as String? ?? 'MM/dd/yyyy',
      timeFormat: prefs['time_format'] as String? ?? '12h',
      
      // Notification Settings
      enableNotifications: prefs['enable_notifications'] as bool? ?? true,
      dailySpendingReminders: prefs['daily_spending_reminders'] as bool? ?? false,
      budgetAlerts: prefs['budget_alerts'] as bool? ?? true,
      weeklyReports: prefs['weekly_reports'] as bool? ?? false,
      dailyReminderTime: prefs['daily_reminder_time'] as String?,
      
      // Privacy & Security
      requireBiometrics: prefs['require_biometrics'] as bool? ?? false,
      hideAmountsInRecents: prefs['hide_amounts_in_recents'] as bool? ?? false,
      enableAnalytics: prefs['enable_analytics'] as bool? ?? true,
      enableCrashReporting: prefs['enable_crash_reporting'] as bool? ?? true,
      
      // Data & Backup
      autoBackup: prefs['auto_backup'] as bool? ?? true,
      backupFrequencyDays: prefs['backup_frequency_days'] as int? ?? 7,
      syncEnabled: prefs['sync_enabled'] as bool? ?? false,
      lastBackupDate: prefs['last_backup_date'] as String?,
      
      // Advanced Settings
      expenseHistoryDays: prefs['expense_history_days'] as int? ?? 365,
      enableDebugMode: prefs['enable_debug_mode'] as bool? ?? false,
      exportFormat: prefs['export_format'] as String? ?? 'json',
      confirmBeforeDelete: prefs['confirm_before_delete'] as bool? ?? true,
      
      // App State
      isFirstLaunch: prefs['is_first_launch'] as bool? ?? true,
      onboardingCompletedAt: prefs['onboarding_completed_at'] as String?,
      appVersion: prefs['app_version'] as String? ?? '1.0.0',
      createdAt: prefs['created_at'] as String? ?? DateTime.now().toIso8601String(),
      updatedAt: prefs['updated_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  const AppSettings._();

  /// Convert to SharedPreferences map
  Map<String, dynamic> toPreferences() {
    return {
      // App Preferences
      'currency': currency,
      'language': language,
      'theme_mode': themeMode,
      if (defaultCategoryId != null) 'default_category_id': defaultCategoryId,
      
      // Display Settings
      'show_cents_in_amounts': showCentsInAmounts,
      'use_compact_expense_view': useCompactExpenseView,
      'show_expense_categories': showExpenseCategories,
      'date_format': dateFormat,
      'time_format': timeFormat,
      
      // Notification Settings
      'enable_notifications': enableNotifications,
      'daily_spending_reminders': dailySpendingReminders,
      'budget_alerts': budgetAlerts,
      'weekly_reports': weeklyReports,
      if (dailyReminderTime != null) 'daily_reminder_time': dailyReminderTime,
      
      // Privacy & Security
      'require_biometrics': requireBiometrics,
      'hide_amounts_in_recents': hideAmountsInRecents,
      'enable_analytics': enableAnalytics,
      'enable_crash_reporting': enableCrashReporting,
      
      // Data & Backup
      'auto_backup': autoBackup,
      'backup_frequency_days': backupFrequencyDays,
      'sync_enabled': syncEnabled,
      if (lastBackupDate != null) 'last_backup_date': lastBackupDate,
      
      // Advanced Settings
      'expense_history_days': expenseHistoryDays,
      'enable_debug_mode': enableDebugMode,
      'export_format': exportFormat,
      'confirm_before_delete': confirmBeforeDelete,
      
      // App State
      'is_first_launch': isFirstLaunch,
      if (onboardingCompletedAt != null) 'onboarding_completed_at': onboardingCompletedAt,
      'app_version': appVersion,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Convert to domain entity
  SettingsEntity toEntity() {
    return SettingsEntity(
      // App Preferences
      currency: currency,
      language: language,
      themeMode: _parseAppThemeMode(themeMode),
      defaultCategoryId: defaultCategoryId,
      
      // Display Settings
      showCentsInAmounts: showCentsInAmounts,
      useCompactExpenseView: useCompactExpenseView,
      showExpenseCategories: showExpenseCategories,
      dateFormat: dateFormat,
      timeFormat: timeFormat,
      
      // Notification Settings
      enableNotifications: enableNotifications,
      dailySpendingReminders: dailySpendingReminders,
      budgetAlerts: budgetAlerts,
      weeklyReports: weeklyReports,
      dailyReminderTime: _parseAppTimeOfDay(dailyReminderTime),
      
      // Privacy & Security
      requireBiometrics: requireBiometrics,
      hideAmountsInRecents: hideAmountsInRecents,
      enableAnalytics: enableAnalytics,
      enableCrashReporting: enableCrashReporting,
      
      // Data & Backup
      autoBackup: autoBackup,
      backupFrequencyDays: backupFrequencyDays,
      syncEnabled: syncEnabled,
      lastBackupDate: _parseDateTime(lastBackupDate),
      
      // Advanced Settings
      expenseHistoryDays: expenseHistoryDays,
      enableDebugMode: enableDebugMode,
      exportFormat: exportFormat,
      confirmBeforeDelete: confirmBeforeDelete,
      
      // App State
      isFirstLaunch: isFirstLaunch,
      onboardingCompletedAt: _parseDateTime(onboardingCompletedAt),
      appVersion: appVersion,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Create from domain entity
 factory AppSettings.fromEntity(SettingsEntity entity) {
   return AppSettings(
     // App Preferences
     currency: entity.currency,
     language: entity.language,
     themeMode: _themeModeToString(entity.themeMode),
     defaultCategoryId: entity.defaultCategoryId,
     
     // Display Settings
     showCentsInAmounts: entity.showCentsInAmounts,
     useCompactExpenseView: entity.useCompactExpenseView,
     showExpenseCategories: entity.showExpenseCategories,
     dateFormat: entity.dateFormat,
     timeFormat: entity.timeFormat,
     
     // Notification Settings
     enableNotifications: entity.enableNotifications,
     dailySpendingReminders: entity.dailySpendingReminders,
     budgetAlerts: entity.budgetAlerts,
     weeklyReports: entity.weeklyReports,
     dailyReminderTime: _timeOfDayToString(entity.dailyReminderTime),
     
     // Privacy & Security
     requireBiometrics: entity.requireBiometrics,
     hideAmountsInRecents: entity.hideAmountsInRecents,
     enableAnalytics: entity.enableAnalytics,
     enableCrashReporting: entity.enableCrashReporting,
     
     // Data & Backup
     autoBackup: entity.autoBackup,
     backupFrequencyDays: entity.backupFrequencyDays,
     syncEnabled: entity.syncEnabled,
     lastBackupDate: entity.lastBackupDate?.toIso8601String(),
     
     // Advanced Settings
     expenseHistoryDays: entity.expenseHistoryDays,
     enableDebugMode: entity.enableDebugMode,
     exportFormat: entity.exportFormat,
     confirmBeforeDelete: entity.confirmBeforeDelete,
     
     // App State
     isFirstLaunch: entity.isFirstLaunch,
     onboardingCompletedAt: entity.onboardingCompletedAt?.toIso8601String(),
     appVersion: entity.appVersion,
     createdAt: entity.createdAt.toIso8601String(),
     updatedAt: entity.updatedAt.toIso8601String(),
   );
 }

 /// Create default settings
 factory AppSettings.defaultSettings() {
   final now = DateTime.now().toIso8601String();
   return AppSettings(
     createdAt: now,
     updatedAt: now,
   );
 }

 /// Helper method to parse ThemeMode
  static AppThemeMode _parseAppThemeMode(String themeModeString) {
   switch (themeModeString.toLowerCase()) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
      default:
        return AppThemeMode.system;
   }
 }

 /// Helper method to convert ThemeMode to string
 static String _themeModeToString(AppThemeMode themeMode) {
   switch (themeMode) {
     case AppThemeMode.light:
       return 'light';
     case AppThemeMode.dark:
       return 'dark';
     case AppThemeMode.system:
       return 'system';
   }
 }

 /// Helper method to parse TimeOfDay from string
  static AppTimeOfDay? _parseAppTimeOfDay(String? timeString) {
   if (timeString == null || timeString.isEmpty) return null;
   
   try {
     final parts = timeString.split(':');
     if (parts.length == 2) {
       final hour = int.parse(parts[0]);
       final minute = int.parse(parts[1]);
       return AppTimeOfDay(hour: hour, minute: minute);
     }
   } catch (e) {
     // Return null if parsing fails
   }
   
   return null;
 }

 /// Helper method to convert TimeOfDay to string
 static String? _timeOfDayToString(AppTimeOfDay? time) {
   if (time == null) return null;
   
   return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
 }

 /// Helper method to parse DateTime from ISO string
 static DateTime? _parseDateTime(String? dateString) {
   if (dateString == null || dateString.isEmpty) return null;
   
   try {
     return DateTime.parse(dateString);
   } catch (e) {
     return null;
   }
 }

 /// Update with current timestamp
 AppSettings withUpdatedTimestamp() {
   return copyWith(updatedAt: DateTime.now().toIso8601String());
 }
}
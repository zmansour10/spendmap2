import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendmap2/features/settings/domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/app_settings.dart';

/// Implementation of SettingsRepository using SharedPreferences
class SettingsRepositoryImpl implements SettingsRepository {
  final SharedPreferences _prefs;
  final StreamController<SettingsEntity> _settingsController;

  SettingsRepositoryImpl(this._prefs) 
      : _settingsController = StreamController<SettingsEntity>.broadcast();

  @override
  Future<SettingsEntity> getSettings() async {
    try {
      final prefsMap = <String, dynamic>{};
      
      // Load all settings from SharedPreferences
      for (final key in _prefs.getKeys()) {
        final value = _prefs.get(key);
        prefsMap[key] = value;
      }

      // Create AppSettings from preferences and convert to entity
      final appSettings = AppSettings.fromPreferences(prefsMap);
      return appSettings.toEntity();
    } catch (e) {
      // Return default settings if loading fails
      return await getDefaultSettings();
    }
  }

  @override
  Future<void> saveSettings(SettingsEntity settings) async {
    try {
      // Validate settings before saving
      final validationErrors = settings.validate();
      if (validationErrors.isNotEmpty) {
        throw SettingsRepositoryException('Invalid settings: ${validationErrors.join(', ')}');
      }

      // Convert to data model and save to preferences
      final appSettings = AppSettings.fromEntity(settings).withUpdatedTimestamp();
      final prefsMap = appSettings.toPreferences();

      // Save all preferences
      await _savePreferencesMap(prefsMap);

      // Notify listeners
      _settingsController.add(settings);
    } catch (e) {
      throw SettingsRepositoryException('Failed to save settings: $e');
    }
  }

  @override
  Future<void> updateSettings(SettingsEntity settings) async {
    try {
      // Get current settings and merge with new ones
      final currentSettings = await getSettings();
      final updatedSettings = settings.copyWith(
        createdAt: currentSettings.createdAt, // Keep original creation date
        updatedAt: DateTime.now(),
      );

      await saveSettings(updatedSettings);
    } catch (e) {
      throw SettingsRepositoryException('Failed to update settings: $e');
    }
  }

  @override
  Future<void> resetSettings() async {
    try {
      // Clear all preferences
      await _prefs.clear();

      // Save default settings
      final defaultSettings = await getDefaultSettings();
      await saveSettings(defaultSettings);
    } catch (e) {
      throw SettingsRepositoryException('Failed to reset settings: $e');
    }
  }

  @override
  Future<void> setCurrency(String currency) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(currency: currency);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setLanguage(String language) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(language: language);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setThemeMode(String themeMode) async {
    final settings = await getSettings();
    final themeModeEnum = _parseAppThemeMode(themeMode);
    final updatedSettings = settings.copyWith(themeMode: themeModeEnum);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setDefaultCategory(int? categoryId) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(defaultCategoryId: categoryId);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setShowCentsInAmounts(bool show) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(showCentsInAmounts: show);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setUseCompactView(bool useCompact) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(useCompactExpenseView: useCompact);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setDateFormat(String format) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(dateFormat: format);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setTimeFormat(String format) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(timeFormat: format);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(enableNotifications: enabled);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setBudgetAlertsEnabled(bool enabled) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(budgetAlerts: enabled);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setDailyReminders(bool enabled, String? time) async {
    final settings = await getSettings();
    final timeOfDay = time != null ? _parseAppTimeOfDay(time) : null;
    final updatedSettings = settings.copyWith(
      dailySpendingReminders: enabled,
      dailyReminderTime: timeOfDay,
    );
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setWeeklyReports(bool enabled) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(weeklyReports: enabled);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setBiometricsRequired(bool required) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(requireBiometrics: required);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setHideAmountsInRecents(bool hide) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(hideAmountsInRecents: hide);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setAnalyticsEnabled(bool enabled) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(enableAnalytics: enabled);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setCrashReportingEnabled(bool enabled) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(enableCrashReporting: enabled);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setAutoBackup(bool enabled) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(autoBackup: enabled);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setBackupFrequency(int days) async {
    if (days < 1 || days > 365) {
      throw SettingsRepositoryException('Backup frequency must be between 1 and 365 days');
    }
    
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(backupFrequencyDays: days);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> updateBackupDate() async {
    final settings = await getSettings();
    final updatedSettings = settings.updateBackupDate();
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setSyncEnabled(bool enabled) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(syncEnabled: enabled);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setExpenseHistoryDays(int days) async {
    if (days < 30 || days > 3650) {
      throw SettingsRepositoryException('Expense history must be between 30 and 3650 days');
    }
    
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(expenseHistoryDays: days);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setDebugMode(bool enabled) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(enableDebugMode: enabled);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setExportFormat(String format) async {
    if (!['json', 'csv', 'summary'].contains(format.toLowerCase())) {
      throw SettingsRepositoryException('Export format must be json, csv, or summary');
    }
    
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(exportFormat: format.toLowerCase());
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setConfirmBeforeDelete(bool confirm) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(confirmBeforeDelete: confirm);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> completeOnboarding() async {
    final settings = await getSettings();
    final updatedSettings = settings.completeOnboarding();
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> setFirstLaunchCompleted() async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(isFirstLaunch: false);
    await updateSettings(updatedSettings);
  }

  @override
  Future<void> updateAppVersion(String version) async {
    final settings = await getSettings();
    final updatedSettings = settings.copyWith(appVersion: version);
    await updateSettings(updatedSettings);
  }

  @override
  Future<bool> validateSettings(SettingsEntity settings) async {
    try {
      final validationErrors = settings.validate();
      return validationErrors.isEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<SettingsEntity> getDefaultSettings() async {
    final now = DateTime.now();
    return SettingsEntity(
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<void> migrateSettings(String fromVersion, String toVersion) async {
    try {
      // Todo: Add migration logic here for future versions
      // For now, just update the app version
      await updateAppVersion(toVersion);
    } catch (e) {
      throw SettingsRepositoryException('Failed to migrate settings: $e');
    }
  }

  @override
  Future<void> importSettings(Map<String, dynamic> settingsData) async {
    try {
      final appSettings = AppSettings.fromJson(settingsData);
      final entity = appSettings.toEntity();
      
      // Validate before importing
      final validationErrors = entity.validate();
      if (validationErrors.isNotEmpty) {
        throw SettingsRepositoryException('Invalid imported settings: ${validationErrors.join(', ')}');
      }

      await saveSettings(entity);
    } catch (e) {
      throw SettingsRepositoryException('Failed to import settings: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> exportSettings() async {
    try {
      final settings = await getSettings();
      final appSettings = AppSettings.fromEntity(settings);
      return appSettings.toJson();
    } catch (e) {
      throw SettingsRepositoryException('Failed to export settings: $e');
    }
  }

  @override
  Stream<SettingsEntity> watchSettings() {
    return _settingsController.stream;
  }

  /// Save preferences map to SharedPreferences
  Future<void> _savePreferencesMap(Map<String, dynamic> prefsMap) async {
    for (final entry in prefsMap.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value == null) {
        await _prefs.remove(key);
      } else if (value is String) {
        await _prefs.setString(key, value);
      } else if (value is int) {
        await _prefs.setInt(key, value);
      } else if (value is double) {
        await _prefs.setDouble(key, value);
      } else if (value is bool) {
        await _prefs.setBool(key, value);
      } else if (value is List<String>) {
        await _prefs.setStringList(key, value);
      } else {
        // Convert other types to string
        await _prefs.setString(key, value.toString());
      }
    }
  }

  /// Parse ThemeMode from string
  AppThemeMode _parseAppThemeMode(String themeModeString) {
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

  /// Parse TimeOfDay from string
  AppTimeOfDay? _parseAppTimeOfDay(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    
    try {
      return AppTimeOfDay.fromString(timeString);
    } catch (e) {
      return null;
    }
  }

  /// Dispose resources
  void dispose() {
    _settingsController.close();
  }
}

/// Custom exception for settings repository operations
class SettingsRepositoryException implements Exception {
  final String message;
  
  const SettingsRepositoryException(this.message);
  
  @override
  String toString() => 'SettingsRepositoryException: $message';
}
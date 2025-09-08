import '../entities/settings_entity.dart';

/// Abstract repository interface for settings operations
abstract class SettingsRepository {
  // Basic operations
  Future<SettingsEntity> getSettings();
  Future<void> saveSettings(SettingsEntity settings);
  Future<void> updateSettings(SettingsEntity settings);
  Future<void> resetSettings();
  
  // Individual setting operations
  Future<void> setCurrency(String currency);
  Future<void> setLanguage(String language);
  Future<void> setThemeMode(String themeMode);
  Future<void> setDefaultCategory(int? categoryId);
  
  // Display settings
  Future<void> setShowCentsInAmounts(bool show);
  Future<void> setUseCompactView(bool useCompact);
  Future<void> setDateFormat(String format);
  Future<void> setTimeFormat(String format);
  
  // Notification settings
  Future<void> setNotificationsEnabled(bool enabled);
  Future<void> setBudgetAlertsEnabled(bool enabled);
  Future<void> setDailyReminders(bool enabled, String? time);
  Future<void> setWeeklyReports(bool enabled);
  
  // Privacy & security
  Future<void> setBiometricsRequired(bool required);
  Future<void> setHideAmountsInRecents(bool hide);
  Future<void> setAnalyticsEnabled(bool enabled);
  Future<void> setCrashReportingEnabled(bool enabled);
  
  // Backup settings
  Future<void> setAutoBackup(bool enabled);
  Future<void> setBackupFrequency(int days);
  Future<void> updateBackupDate();
  Future<void> setSyncEnabled(bool enabled);
  
  // Advanced settings
  Future<void> setExpenseHistoryDays(int days);
  Future<void> setDebugMode(bool enabled);
  Future<void> setExportFormat(String format);
  Future<void> setConfirmBeforeDelete(bool confirm);
  
  // App state
  Future<void> completeOnboarding();
  Future<void> setFirstLaunchCompleted();
  Future<void> updateAppVersion(String version);
  
  // Validation and defaults
  Future<bool> validateSettings(SettingsEntity settings);
  Future<SettingsEntity> getDefaultSettings();
  Future<void> migrateSettings(String fromVersion, String toVersion);
  
  // Bulk operations
  Future<void> importSettings(Map<String, dynamic> settingsData);
  Future<Map<String, dynamic>> exportSettings();
  
  // Watch for changes (for reactive UI)
  Stream<SettingsEntity> watchSettings();
}
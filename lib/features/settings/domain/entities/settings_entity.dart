import 'package:flutter/material.dart';

/// Domain entity representing app settings
/// Contains all user preferences and app configuration
class SettingsEntity {
  // App Preferences
  final String currency;
  final String language;
  final AppThemeMode themeMode;
  final int? defaultCategoryId;
  
  // Display Settings
  final bool showCentsInAmounts;
  final bool useCompactExpenseView;
  final bool showExpenseCategories;
  final String dateFormat;
  final String timeFormat;
  
  // Notification Settings
  final bool enableNotifications;
  final bool dailySpendingReminders;
  final bool budgetAlerts;
  final bool weeklyReports;
  final AppTimeOfDay? dailyReminderTime;
  
  // Privacy & Security
  final bool requireBiometrics;
  final bool hideAmountsInRecents;
  final bool enableAnalytics;
  final bool enableCrashReporting;
  
  // Data & Backup
  final bool autoBackup;
  final int backupFrequencyDays;
  final bool syncEnabled;
  final DateTime? lastBackupDate;
  
  // Advanced Settings
  final int expenseHistoryDays;
  final bool enableDebugMode;
  final String exportFormat;
  final bool confirmBeforeDelete;
  
  // App State
  final bool isFirstLaunch;
  final DateTime? onboardingCompletedAt;
  final String appVersion;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SettingsEntity({
    // App Preferences
    this.currency = 'USD',
    this.language = 'en',
    this.themeMode = AppThemeMode.system,
    this.defaultCategoryId,
    
    // Display Settings
    this.showCentsInAmounts = true,
    this.useCompactExpenseView = false,
    this.showExpenseCategories = true,
    this.dateFormat = 'MM/dd/yyyy',
    this.timeFormat = '12h',
    
    // Notification Settings
    this.enableNotifications = true,
    this.dailySpendingReminders = false,
    this.budgetAlerts = true,
    this.weeklyReports = false,
    this.dailyReminderTime,
    
    // Privacy & Security
    this.requireBiometrics = false,
    this.hideAmountsInRecents = false,
    this.enableAnalytics = true,
    this.enableCrashReporting = true,
    
    // Data & Backup
    this.autoBackup = true,
    this.backupFrequencyDays = 7,
    this.syncEnabled = false,
    this.lastBackupDate,
    
    // Advanced Settings
    this.expenseHistoryDays = 365,
    this.enableDebugMode = false,
    this.exportFormat = 'json',
    this.confirmBeforeDelete = true,
    
    // App State
    this.isFirstLaunch = true,
    this.onboardingCompletedAt,
    this.appVersion = '1.0.0',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Business logic methods

  /// Check if onboarding is completed
  bool get hasCompletedOnboarding => onboardingCompletedAt != null;

  /// Check if app has been used before
  bool get isExistingUser => !isFirstLaunch;

  /// Check if backup is due
  bool get isBackupDue {
    if (!autoBackup || lastBackupDate == null) return autoBackup;
    
    final daysSinceBackup = DateTime.now().difference(lastBackupDate!).inDays;
    return daysSinceBackup >= backupFrequencyDays;
  }

  /// Get localized currency symbol
  String get currencySymbol {
    switch (currency.toLowerCase()) {
      case 'usd':
        return '\$';
      case 'eur':
        return '€';
      case 'gbp':
        return '£';
      case 'jpy':
        return '¥';
      case 'cad':
        return 'C\$';
      case 'aud':
        return 'A\$';
      case 'chf':
        return 'CHF ';
      case 'cny':
        return '¥';
      case 'sek':
        return 'kr ';
      case 'nok':
        return 'kr ';
      case 'mxn':
        return 'MX\$';
      case 'sgd':
        return 'S\$';
      case 'hkd':
        return 'HK\$';
      case 'nzd':
        return 'NZ\$';
      case 'krw':
        return '₩';
      case 'try':
        return '₺';
      case 'rub':
        return '₽';
      case 'inr':
        return '₹';
      case 'brl':
        return 'R\$';
      default:
        return '${currency.toUpperCase()} ';
    }
  }

  /// Get currency display name
  String get currencyDisplayName {
    switch (currency.toLowerCase()) {
      case 'usd':
        return 'US Dollar';
      case 'eur':
        return 'Euro';
      case 'gbp':
        return 'British Pound';
      case 'jpy':
        return 'Japanese Yen';
      case 'cad':
        return 'Canadian Dollar';
      case 'aud':
        return 'Australian Dollar';
      case 'chf':
        return 'Swiss Franc';
      case 'cny':
        return 'Chinese Yuan';
      case 'sek':
        return 'Swedish Krona';
      case 'nok':
        return 'Norwegian Krone';
      case 'mxn':
        return 'Mexican Peso';
      case 'sgd':
        return 'Singapore Dollar';
      case 'hkd':
        return 'Hong Kong Dollar';
      case 'nzd':
        return 'New Zealand Dollar';
      case 'krw':
        return 'South Korean Won';
      case 'try':
        return 'Turkish Lira';
      case 'rub':
        return 'Russian Ruble';
      case 'inr':
        return 'Indian Rupee';
      case 'brl':
        return 'Brazilian Real';
      default:
        return currency.toUpperCase();
    }
  }

  /// Get theme display name
  String get themeDisplayName {
    switch (themeMode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }

  /// Format time based on settings
  String formatTime(AppTimeOfDay time) {
    if (timeFormat == '24h') {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final period = time.period == AppDayPeriod.am ? 'AM' : 'PM';
      return '$hour:${time.minute.toString().padLeft(2, '0')} $period';
    }
  }

  /// Format date based on settings
  String formatDate(DateTime date) {
    // Simplified date formatting - in real app would use intl package
    switch (dateFormat.toLowerCase()) {
      case 'mm/dd/yyyy':
        return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
      case 'dd/mm/yyyy':
        return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      case 'yyyy-mm-dd':
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      case 'dd-mm-yyyy':
        return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
      default:
        return date.toString().split(' ')[0];
    }
  }

  /// Validate settings
  List<String> validate() {
    final errors = <String>[];
    
    if (currency.isEmpty) {
      errors.add('Currency cannot be empty');
    }
    
    if (language.isEmpty) {
      errors.add('Language cannot be empty');
    }
    
    if (backupFrequencyDays < 1 || backupFrequencyDays > 365) {
      errors.add('Backup frequency must be between 1 and 365 days');
    }
    
    if (expenseHistoryDays < 30 || expenseHistoryDays > 3650) {
      errors.add('Expense history must be between 30 and 3650 days');
    }
    
    if (!['json', 'csv', 'summary'].contains(exportFormat.toLowerCase())) {
      errors.add('Export format must be json, csv, or summary');
    }
    
    return errors;
  }

  /// Create a copy with modified properties
  SettingsEntity copyWith({
    String? currency,
    String? language,
    AppThemeMode? themeMode,
    int? defaultCategoryId,
    bool? showCentsInAmounts,
    bool? useCompactExpenseView,
    bool? showExpenseCategories,
    String? dateFormat,
    String? timeFormat,
    bool? enableNotifications,
    bool? dailySpendingReminders,
    bool? budgetAlerts,
    bool? weeklyReports,
    AppTimeOfDay? dailyReminderTime,
    bool? requireBiometrics,
    bool? hideAmountsInRecents,
    bool? enableAnalytics,
    bool? enableCrashReporting,
    bool? autoBackup,
    int? backupFrequencyDays,
    bool? syncEnabled,
    DateTime? lastBackupDate,
    int? expenseHistoryDays,
    bool? enableDebugMode,
    String? exportFormat,
    bool? confirmBeforeDelete,
    bool? isFirstLaunch,
    DateTime? onboardingCompletedAt,
    String? appVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SettingsEntity(
      currency: currency ?? this.currency,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      defaultCategoryId: defaultCategoryId ?? this.defaultCategoryId,
      showCentsInAmounts: showCentsInAmounts ?? this.showCentsInAmounts,
      useCompactExpenseView: useCompactExpenseView ?? this.useCompactExpenseView,
      showExpenseCategories: showExpenseCategories ?? this.showExpenseCategories,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      dailySpendingReminders: dailySpendingReminders ?? this.dailySpendingReminders,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      weeklyReports: weeklyReports ?? this.weeklyReports,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      requireBiometrics: requireBiometrics ?? this.requireBiometrics,
      hideAmountsInRecents: hideAmountsInRecents ?? this.hideAmountsInRecents,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      enableCrashReporting: enableCrashReporting ?? this.enableCrashReporting,
      autoBackup: autoBackup ?? this.autoBackup,
      backupFrequencyDays: backupFrequencyDays ?? this.backupFrequencyDays,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      lastBackupDate: lastBackupDate ?? this.lastBackupDate,
      expenseHistoryDays: expenseHistoryDays ?? this.expenseHistoryDays,
      enableDebugMode: enableDebugMode ?? this.enableDebugMode,
      exportFormat: exportFormat ?? this.exportFormat,
      confirmBeforeDelete: confirmBeforeDelete ?? this.confirmBeforeDelete,
      isFirstLaunch: isFirstLaunch ?? this.isFirstLaunch,
      onboardingCompletedAt: onboardingCompletedAt ?? this.onboardingCompletedAt,
      appVersion: appVersion ?? this.appVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Mark onboarding as completed
  SettingsEntity completeOnboarding() {
    return copyWith(
      isFirstLaunch: false,
      onboardingCompletedAt: DateTime.now(),
    );
  }

  /// Update backup date
  SettingsEntity updateBackupDate() {
    return copyWith(
      lastBackupDate: DateTime.now(),
    );
  }

  /// Reset to defaults (keeping app state)
  SettingsEntity resetToDefaults() {
    return SettingsEntity(
      // Keep app state
      isFirstLaunch: isFirstLaunch,
      onboardingCompletedAt: onboardingCompletedAt,
      appVersion: appVersion,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      // Reset other settings to defaults
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsEntity &&
        other.currency == currency &&
        other.language == language &&
        other.themeMode == themeMode &&
        other.defaultCategoryId == defaultCategoryId &&
        other.showCentsInAmounts == showCentsInAmounts &&
        other.useCompactExpenseView == useCompactExpenseView &&
        other.enableNotifications == enableNotifications &&
        other.requireBiometrics == requireBiometrics &&
        other.autoBackup == autoBackup;
    // Simplified comparison - in real app would compare all fields
  }

  @override
  int get hashCode {
    return Object.hash(
      currency,
      language,
      themeMode,
      defaultCategoryId,
      showCentsInAmounts,
      useCompactExpenseView,
      enableNotifications,
      requireBiometrics,
      autoBackup,
    );
  }

  @override
  String toString() {
    return 'SettingsEntity(currency: $currency, language: $language, theme: $themeMode, firstLaunch: $isFirstLaunch)';
  }
}

/// Domain-specific theme mode enum
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Domain-specific time of day value object
class AppTimeOfDay {
  final int hour;
  final int minute;

  const AppTimeOfDay({
    required this.hour,
    required this.minute,
  });

  /// Get hour in 12-hour format (1-12)
  int get hourOfPeriod {
    if (hour == 0) return 12;
    if (hour > 12) return hour - 12;
    return hour;
  }

  /// Get period (AM/PM)
  AppDayPeriod get period {
    return hour < 12 ? AppDayPeriod.am : AppDayPeriod.pm;
  }

  /// Create from string (HH:mm)
  factory AppTimeOfDay.fromString(String timeString) {
    final parts = timeString.split(':');
    if (parts.length != 2) {
      throw ArgumentError('Invalid time format. Expected HH:mm');
    }
    
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    if (hour < 0 || hour > 23) {
      throw ArgumentError('Hour must be between 0 and 23');
    }
    if (minute < 0 || minute > 59) {
      throw ArgumentError('Minute must be between 0 and 59');
    }
    
    return AppTimeOfDay(hour: hour, minute: minute);
  }

  /// Convert to string (HH:mm)
  String toTimeString() {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppTimeOfDay && other.hour == hour && other.minute == minute;
  }

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => 'AppTimeOfDay(${toTimeString()})';
}

/// Domain-specific day period enum
enum AppDayPeriod {
  am,
  pm,
}

/// Supported currencies
class SupportedCurrencies {
  static const List<CurrencyInfo> all = [
    CurrencyInfo(code: 'USD', name: 'US Dollar', symbol: '\$'),
    CurrencyInfo(code: 'EUR', name: 'Euro', symbol: '€'),
    CurrencyInfo(code: 'GBP', name: 'British Pound', symbol: '£'),
    CurrencyInfo(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
    CurrencyInfo(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$'),
    CurrencyInfo(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$'),
    CurrencyInfo(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF '),
    CurrencyInfo(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
    CurrencyInfo(code: 'SEK', name: 'Swedish Krona', symbol: 'kr '),
    CurrencyInfo(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr '),
    CurrencyInfo(code: 'MXN', name: 'Mexican Peso', symbol: 'MX\$'),
    CurrencyInfo(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$'),
    CurrencyInfo(code: 'HKD', name: 'Hong Kong Dollar', symbol: 'HK\$'),
    CurrencyInfo(code: 'NZD', name: 'New Zealand Dollar', symbol: 'NZ\$'),
    CurrencyInfo(code: 'KRW', name: 'South Korean Won', symbol: '₩'),
    CurrencyInfo(code: 'TRY', name: 'Turkish Lira', symbol: '₺'),
    CurrencyInfo(code: 'RUB', name: 'Russian Ruble', symbol: '₽'),
    CurrencyInfo(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
    CurrencyInfo(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$'),
  ];

  /// Get currency by code
  static CurrencyInfo? getByCode(String code) {
    try {
      return all.firstWhere((currency) => currency.code.toLowerCase() == code.toLowerCase());
    } catch (e) {
      return null;
    }
  }
}

/// Currency information
class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;

  const CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
  });

  @override
  String toString() => '$code - $name';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CurrencyInfo && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}

/// Supported languages
class SupportedLanguages {
  static const List<LanguageInfo> all = [
    LanguageInfo(code: 'en', name: 'English', nativeName: 'English'),
    LanguageInfo(code: 'es', name: 'Spanish', nativeName: 'Español'),
    LanguageInfo(code: 'de', name: 'German', nativeName: 'Deutsch'),
    LanguageInfo(code: 'fr', name: 'French', nativeName: 'Français'),
    LanguageInfo(code: 'it', name: 'Italian', nativeName: 'Italiano'),
    LanguageInfo(code: 'pt', name: 'Portuguese', nativeName: 'Português'),
    LanguageInfo(code: 'ru', name: 'Russian', nativeName: 'Русский'),
    LanguageInfo(code: 'ja', name: 'Japanese', nativeName: '日本語'),
    LanguageInfo(code: 'ko', name: 'Korean', nativeName: '한국어'),
    LanguageInfo(code: 'zh', name: 'Chinese', nativeName: '中文'),
  ];

  /// Get language by code
  static LanguageInfo? getByCode(String code) {
    try {
      return all.firstWhere((language) => language.code.toLowerCase() == code.toLowerCase());
    } catch (e) {
      return null;
    }
  }
}

/// Language information
class LanguageInfo {
  final String code;
  final String name;
  final String nativeName;

  const LanguageInfo({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  @override
  String toString() => '$nativeName ($name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageInfo && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;
}

/// Date format options
class DateFormatOptions {
  static const List<String> formats = [
    'MM/dd/yyyy',
    'dd/MM/yyyy',
    'yyyy-MM-dd',
    'dd-MM-yyyy',
    'MMM dd, yyyy',
    'dd MMM yyyy',
  ];

  /// Get display name for format
  static String getDisplayName(String format) {
    final now = DateTime.now();
    switch (format) {
      case 'MM/dd/yyyy':
        return 'MM/dd/yyyy (US)';
      case 'dd/MM/yyyy':
        return 'dd/MM/yyyy (European)';
      case 'yyyy-MM-dd':
        return 'yyyy-MM-dd (ISO)';
      case 'dd-MM-yyyy':
        return 'dd-MM-yyyy';
      case 'MMM dd, yyyy':
        return 'MMM dd, yyyy (Long)';
      case 'dd MMM yyyy':
        return 'dd MMM yyyy (Long)';
      default:
        return format;
    }
  }
}
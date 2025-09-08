import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendmap2/features/settings/data/models/app_settings.dart';
import 'package:spendmap2/features/settings/domain/entities/settings_entity.dart';

void main() {
  group('Settings System Tests', () {
    test('should create settings entity with defaults', () {
      final now = DateTime.now();
      final settings = SettingsEntity(
        createdAt: now,
        updatedAt: now,
      );

      expect(settings.currency, equals('USD'));
      expect(settings.language, equals('en'));
      expect(settings.themeMode, equals(AppThemeMode.system)); 
      expect(settings.showCentsInAmounts, isTrue);
      expect(settings.enableNotifications, isTrue);
      expect(settings.autoBackup, isTrue);
      expect(settings.isFirstLaunch, isTrue);
    });

    test('should validate settings correctly', () {
      final now = DateTime.now();
      
      // Valid settings
      final validSettings = SettingsEntity(
        currency: 'USD',
        language: 'en',
        backupFrequencyDays: 7,
        expenseHistoryDays: 365,
        exportFormat: 'json',
       createdAt: now,
       updatedAt: now,
     );
     expect(validSettings.validate(), isEmpty);

     // Invalid settings - empty currency
     final invalidCurrency = SettingsEntity(
       currency: '',
       language: 'en',
       createdAt: now,
       updatedAt: now,
     );
     expect(invalidCurrency.validate(), isNotEmpty);
     expect(invalidCurrency.validate().first, contains('Currency cannot be empty'));

     // Invalid settings - backup frequency out of range
     final invalidBackupFreq = SettingsEntity(
       backupFrequencyDays: 400,
       createdAt: now,
       updatedAt: now,
     );
     expect(invalidBackupFreq.validate(), isNotEmpty);
     expect(invalidBackupFreq.validate().first, contains('Backup frequency must be between'));

     // Invalid export format
     final invalidExportFormat = SettingsEntity(
       exportFormat: 'xml',
       createdAt: now,
       updatedAt: now,
     );
     expect(invalidExportFormat.validate(), isNotEmpty);
     expect(invalidExportFormat.validate().first, contains('Export format must be'));
   });

   test('should handle currency formatting correctly', () {
     final now = DateTime.now();
     
     // USD with cents
     final usdSettings = SettingsEntity(
       currency: 'USD',
       showCentsInAmounts: true,
       createdAt: now,
       updatedAt: now,
     );
     //expect(usdSettings.formatAmount(25.50), equals('\$25.50'));
     expect(usdSettings.currencySymbol, equals('\$'));
     expect(usdSettings.currencyDisplayName, equals('US Dollar'));

     // EUR without cents
     final eurSettings = SettingsEntity(
       currency: 'EUR',
       showCentsInAmounts: false,
       createdAt: now,
       updatedAt: now,
     );
     //expect(eurSettings.formatAmount(25.50), equals('€26'));
     expect(eurSettings.currencySymbol, equals('€'));
     expect(eurSettings.currencyDisplayName, equals('Euro'));

     // Custom currency
     final customSettings = SettingsEntity(
       currency: 'XYZ',
       createdAt: now,
       updatedAt: now,
     );
     expect(customSettings.currencySymbol, equals('XYZ '));
     expect(customSettings.currencyDisplayName, equals('XYZ'));
   });

   test('should handle date formatting correctly', () {
     final now = DateTime.now();
     final testDate = DateTime(2024, 3, 15);
     
     // MM/dd/yyyy format
     final usSettings = SettingsEntity(
       dateFormat: 'MM/dd/yyyy',
       createdAt: now,
       updatedAt: now,
     );
     expect(usSettings.formatDate(testDate), equals('03/15/2024'));

     // dd/MM/yyyy format
     final ukSettings = SettingsEntity(
       dateFormat: 'dd/MM/yyyy',
       createdAt: now,
       updatedAt: now,
     );
     expect(ukSettings.formatDate(testDate), equals('15/03/2024'));

     // yyyy-MM-dd format
     final isoSettings = SettingsEntity(
       dateFormat: 'yyyy-MM-dd',
       createdAt: now,
       updatedAt: now,
     );
     expect(isoSettings.formatDate(testDate), equals('2024-03-15'));
   });

   test('should handle AppTimeOfDay correctly', () {
      // Test creation from string
      final time1 = AppTimeOfDay.fromString('14:30');
      expect(time1.hour, equals(14));
      expect(time1.minute, equals(30));
      expect(time1.hourOfPeriod, equals(2));
      expect(time1.period, equals(AppDayPeriod.pm));

      // Test conversion to string
      expect(time1.toTimeString(), equals('14:30'));

      // Test AM time
      final time2 = AppTimeOfDay.fromString('09:15');
      expect(time2.period, equals(AppDayPeriod.am));
      expect(time2.hourOfPeriod, equals(9));

      // Test midnight
      final midnight = AppTimeOfDay.fromString('00:00');
      expect(midnight.period, equals(AppDayPeriod.am));
      expect(midnight.hourOfPeriod, equals(12));

      // Test equality
      final time3 = AppTimeOfDay(hour: 14, minute: 30);
      expect(time1, equals(time3));
    });

   test('should handle business logic correctly', () {
     final now = DateTime.now();
     
     // Test onboarding completion
     final beforeOnboarding = SettingsEntity(
       isFirstLaunch: true,
       onboardingCompletedAt: null,
       createdAt: now,
       updatedAt: now,
     );
     expect(beforeOnboarding.hasCompletedOnboarding, isFalse);
     expect(beforeOnboarding.isExistingUser, isFalse);

     final afterOnboarding = beforeOnboarding.completeOnboarding();
     expect(afterOnboarding.hasCompletedOnboarding, isTrue);
     expect(afterOnboarding.isFirstLaunch, isFalse);
     expect(afterOnboarding.onboardingCompletedAt, isNotNull);

     // Test backup due logic
     final backupSettings = SettingsEntity(
       autoBackup: true,
       backupFrequencyDays: 7,
       lastBackupDate: now.subtract(const Duration(days: 10)),
       createdAt: now,
       updatedAt: now,
     );
     expect(backupSettings.isBackupDue, isTrue);

     final recentBackupSettings = SettingsEntity(
       autoBackup: true,
       backupFrequencyDays: 7,
       lastBackupDate: now.subtract(const Duration(days: 3)),
       createdAt: now,
       updatedAt: now,
     );
     expect(recentBackupSettings.isBackupDue, isFalse);

     // Auto backup disabled
     final noAutoBackupSettings = SettingsEntity(
       autoBackup: false,
       createdAt: now,
       updatedAt: now,
     );
     expect(noAutoBackupSettings.isBackupDue, isFalse);
   });

   test('should handle copyWith correctly', () {
     final now = DateTime.now();
     final originalSettings = SettingsEntity(
       currency: 'USD',
       language: 'en',
       themeMode: AppThemeMode.light,
       createdAt: now,
       updatedAt: now,
     );

     final updatedSettings = originalSettings.copyWith(
       currency: 'EUR',
       themeMode: AppThemeMode.dark,
     );

     expect(updatedSettings.currency, equals('EUR'));
     expect(updatedSettings.themeMode, equals(AppThemeMode.dark));
     expect(updatedSettings.language, equals('en')); // Unchanged
     expect(updatedSettings.createdAt, equals(now)); // Unchanged
     expect(updatedSettings.updatedAt.isAfter(now), isTrue); // Should be updated
   });

   test('should convert between entity and model correctly', () {
     final now = DateTime.now();
     final entity = SettingsEntity(
       currency: 'EUR',
       language: 'de',
       themeMode: AppThemeMode.dark,
       showCentsInAmounts: false,
       enableNotifications: false,
       createdAt: now,
       updatedAt: now,
     );

     // Convert to model
     final model = AppSettings.fromEntity(entity);
     expect(model.currency, equals('EUR'));
     expect(model.language, equals('de'));
     expect(model.themeMode, equals('dark'));
     expect(model.showCentsInAmounts, isFalse);
     expect(model.enableNotifications, isFalse);

     // Convert back to entity
     final convertedEntity = model.toEntity();
     expect(convertedEntity.currency, equals('EUR'));
     expect(convertedEntity.language, equals('de'));
     expect(convertedEntity.themeMode, equals(AppThemeMode.dark));
     expect(convertedEntity.showCentsInAmounts, isFalse);
     expect(convertedEntity.enableNotifications, isFalse);
   });

   test('should handle preferences conversion correctly', () {
     final prefsMap = {
       'currency': 'GBP',
       'language': 'en',
       'theme_mode': 'light',
       'show_cents_in_amounts': false,
       'enable_notifications': true,
       'backup_frequency_days': 14,
       'is_first_launch': false,
       'created_at': DateTime.now().toIso8601String(),
       'updated_at': DateTime.now().toIso8601String(),
     };

     // Convert from preferences
     final model = AppSettings.fromPreferences(prefsMap);
     expect(model.currency, equals('GBP'));
     expect(model.language, equals('en'));
     expect(model.themeMode, equals('light'));
     expect(model.showCentsInAmounts, isFalse);
     expect(model.backupFrequencyDays, equals(14));

     // Convert back to preferences
     final convertedPrefs = model.toPreferences();
     expect(convertedPrefs['currency'], equals('GBP'));
     expect(convertedPrefs['theme_mode'], equals('light'));
     expect(convertedPrefs['show_cents_in_amounts'], isFalse);
     expect(convertedPrefs['backup_frequency_days'], equals(14));
   });

   test('should create default settings correctly', () {
     final defaultSettings = AppSettings.defaultSettings();
     
     expect(defaultSettings.currency, equals('USD'));
     expect(defaultSettings.language, equals('en'));
     expect(defaultSettings.themeMode, equals('system'));
     expect(defaultSettings.showCentsInAmounts, isTrue);
     expect(defaultSettings.enableNotifications, isTrue);
     expect(defaultSettings.autoBackup, isTrue);
     expect(defaultSettings.isFirstLaunch, isTrue);
     expect(defaultSettings.createdAt, isNotNull);
     expect(defaultSettings.updatedAt, isNotNull);
   });

   test('should handle supported currencies correctly', () {
     // Test getting currency by code
     final usdCurrency = SupportedCurrencies.getByCode('USD');
     expect(usdCurrency, isNotNull);
     expect(usdCurrency!.name, equals('US Dollar'));
     expect(usdCurrency.symbol, equals('\$'));

     final eurCurrency = SupportedCurrencies.getByCode('eur'); // Case insensitive
     expect(eurCurrency, isNotNull);
     expect(eurCurrency!.name, equals('Euro'));

     // Test non-existent currency
     final nonExistent = SupportedCurrencies.getByCode('XYZ');
     expect(nonExistent, isNull);

     // Test currency equality
     final usd1 = SupportedCurrencies.getByCode('USD');
     final usd2 = SupportedCurrencies.getByCode('USD');
     expect(usd1, equals(usd2));
   });

   test('should handle supported languages correctly', () {
     // Test getting language by code
     final englishLang = SupportedLanguages.getByCode('en');
     expect(englishLang, isNotNull);
     expect(englishLang!.name, equals('English'));
     expect(englishLang.nativeName, equals('English'));

     final germanLang = SupportedLanguages.getByCode('DE'); // Case insensitive
     expect(germanLang, isNotNull);
     expect(germanLang!.name, equals('German'));
     expect(germanLang.nativeName, equals('Deutsch'));

     // Test non-existent language
     final nonExistent = SupportedLanguages.getByCode('xyz');
     expect(nonExistent, isNull);
   });

   test('should handle date format options correctly', () {
     final formats = DateFormatOptions.formats;
     expect(formats, isNotEmpty);
     expect(formats, contains('MM/dd/yyyy'));
     expect(formats, contains('dd/MM/yyyy'));
     expect(formats, contains('yyyy-MM-dd'));

     // Test display names
     expect(DateFormatOptions.getDisplayName('MM/dd/yyyy'), contains('US'));
     expect(DateFormatOptions.getDisplayName('dd/MM/yyyy'), contains('European'));
     expect(DateFormatOptions.getDisplayName('yyyy-MM-dd'), contains('ISO'));
   });

   test('should handle reset to defaults correctly', () {
     final now = DateTime.now();
     final customSettings = SettingsEntity(
       currency: 'EUR',
       language: 'de',
       themeMode: AppThemeMode.dark,
       isFirstLaunch: false,
       onboardingCompletedAt: now,
       createdAt: now,
       updatedAt: now,
     );

     final resetSettings = customSettings.resetToDefaults();
     
     // Should reset to defaults
     expect(resetSettings.currency, equals('USD'));
     expect(resetSettings.language, equals('en'));
     expect(resetSettings.themeMode, equals(AppThemeMode.system));
     
     // Should keep app state
     expect(resetSettings.isFirstLaunch, isFalse);
     expect(resetSettings.onboardingCompletedAt, equals(now));
     expect(resetSettings.createdAt, equals(now));
     expect(resetSettings.updatedAt.isAfter(now), isTrue);
   });

   test('should handle theme mode display names correctly', () {
     final now = DateTime.now();
     
     final lightSettings = SettingsEntity(
       themeMode: AppThemeMode.light,
       createdAt: now,
       updatedAt: now,
     );
     expect(lightSettings.themeDisplayName, equals('Light'));

     final darkSettings = SettingsEntity(
       themeMode: AppThemeMode.dark,
       createdAt: now,
       updatedAt: now,
     );
     expect(darkSettings.themeDisplayName, equals('Dark'));

     final systemSettings = SettingsEntity(
       themeMode: AppThemeMode.system,
       createdAt: now,
       updatedAt: now,
     );
     expect(systemSettings.themeDisplayName, equals('System'));
   });
 });
}
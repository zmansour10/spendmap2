import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../extensions/settings_ui_extensions.dart';

part 'settings_provider.g.dart';

// SharedPreferences Provider
@riverpod
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return await SharedPreferences.getInstance();
}

// Settings Repository Provider
@riverpod
SettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  final prefs = ref.watch(sharedPreferencesProvider).value;
  if (prefs == null) {
    throw Exception('SharedPreferences not initialized');
  }
  return SettingsRepositoryImpl(prefs);
}

// Settings Provider - Main settings state
@riverpod
class Settings extends _$Settings {
  @override
  Future<SettingsEntity> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    return await repository.getSettings();
  }

  /// Update settings
  Future<void> updateSettings(SettingsEntity settings) async {
    final repository = ref.watch(settingsRepositoryProvider);
    
    // Optimistic update
    state = AsyncValue.data(settings);
    
    try {
      await repository.updateSettings(settings);
      // Refresh to get the actual saved state
      ref.invalidateSelf();
    } catch (e) {
      // Revert on error
      ref.invalidateSelf();
      rethrow;
    }
  }

  /// Reset settings to defaults
  Future<void> resetSettings() async {
    final repository = ref.watch(settingsRepositoryProvider);
    
    try {
      await repository.resetSettings();
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    final repository = ref.watch(settingsRepositoryProvider);
    
    try {
      await repository.completeOnboarding();
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }

  /// Update specific setting methods
  Future<void> setCurrency(String currency) async {
    final repository = ref.watch(settingsRepositoryProvider);
    await repository.setCurrency(currency);
    ref.invalidateSelf();
  }

  Future<void> setLanguage(String language) async {
    final repository = ref.watch(settingsRepositoryProvider);
    await repository.setLanguage(language);
    ref.invalidateSelf();
  }

  Future<void> setThemeMode(String themeMode) async {
    final repository = ref.watch(settingsRepositoryProvider);
    await repository.setThemeMode(themeMode);
    ref.invalidateSelf();
  }

  Future<void> setDefaultCategory(int? categoryId) async {
    final repository = ref.watch(settingsRepositoryProvider);
    await repository.setDefaultCategory(categoryId);
    ref.invalidateSelf();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final repository = ref.watch(settingsRepositoryProvider);
    await repository.setNotificationsEnabled(enabled);
    ref.invalidateSelf();
  }

  Future<void> setBiometricsRequired(bool required) async {
    final repository = ref.watch(settingsRepositoryProvider);
    await repository.setBiometricsRequired(required);
    ref.invalidateSelf();
  }

  Future<void> setAutoBackup(bool enabled) async {
    final repository = ref.watch(settingsRepositoryProvider);
    await repository.setAutoBackup(enabled);
    ref.invalidateSelf();
  }

  Future<void> updateBackupDate() async {
    final repository = ref.watch(settingsRepositoryProvider);
    await repository.updateBackupDate();
    ref.invalidateSelf();
  }
}

// Current Theme Provider (derived from settings)
@riverpod
ThemeMode currentTheme(CurrentThemeRef ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.when(
    data: (settings) => settings.themeMode.toFlutterThemeMode(), 
    loading: () => ThemeMode.system,
    error: (_, __) => ThemeMode.system,
  );
}

// Current Currency Provider (derived from settings)
@riverpod
String currentCurrency(ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.when(
    data: (settings) => settings.currency,
    loading: () => 'USD',
    error: (_, __) => 'USD',
  );
}

// Current Language Provider (derived from settings)
@riverpod
String currentLanguage(ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.when(
    data: (settings) => settings.language,
    loading: () => 'en',
    error: (_, __) => 'en',
  );
}

// Is First Launch Provider
@riverpod
bool isFirstLaunch(ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.when(
    data: (settings) => settings.isFirstLaunch,
    loading: () => true,
    error: (_, __) => true,
  );
}

// Has Completed Onboarding Provider
@riverpod
bool hasCompletedOnboarding(ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.when(
    data: (settings) => settings.hasCompletedOnboarding,
    loading: () => false,
    error: (_, __) => false,
  );
}

// Settings Validation Provider
@riverpod
Future<bool> settingsValidation(ref, SettingsEntity settings) async {
  final repository = ref.watch(settingsRepositoryProvider);
  return await repository.validateSettings(settings);
}

// Export Settings Provider
@riverpod
Future<Map<String, dynamic>> exportSettings(ref) async {
  final repository = ref.watch(settingsRepositoryProvider);
  return await repository.exportSettings();
}

// Import Settings Provider
@riverpod
class ImportSettings extends _$ImportSettings {
  @override
  Future<bool> build() async => false;

  Future<bool> importSettingsData(Map<String, dynamic> settingsData) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.watch(settingsRepositoryProvider);
      await repository.importSettings(settingsData);
      
      // Refresh settings after import
      ref.invalidate(settingsProvider);
      
      state = const AsyncValue.data(true);
      return true;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }
}

// Settings Stream Provider (for real-time updates)
@riverpod
Stream<SettingsEntity> settingsStream(ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return repository.watchSettings();
}

// Currency Format Provider (helper for UI)
@riverpod
String Function(double) currencyFormatter(ref) {
  final settingsAsync = ref.watch(settingsProvider);
  
  return settingsAsync.when(
    data: (settings) => (double amount) => settings.formatAmount(amount),
    loading: () => (double amount) => '\$${amount.toStringAsFixed(2)}',
    error: (_, __) => (double amount) => '\$${amount.toStringAsFixed(2)}',
  );
}

// Date Format Provider (helper for UI)
@riverpod
String Function(DateTime) dateFormatter(ref) {
  final settingsAsync = ref.watch(settingsProvider);
  
  return settingsAsync.when(
    data: (settings) => (DateTime date) => settings.formatDate(date),
    loading: () => (DateTime date) => date.toString().split(' ')[0],
    error: (_, __) => (DateTime date) => date.toString().split(' ')[0],
  );
}

// Backup Due Provider
@riverpod
bool isBackupDue(ref) {
  final settingsAsync = ref.watch(settingsProvider);
  return settingsAsync.when(
    data: (settings) => settings.isBackupDue,
    loading: () => false,
    error: (_, __) => false,
  );
}
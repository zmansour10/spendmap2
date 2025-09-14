import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../settings/presentation/providers/settings_provider.dart';

part 'locale_provider.g.dart';

/// Supported locales for the application
const List<Locale> supportedLocales = [
  Locale('en', 'US'), // English
  Locale('es', 'ES'), // Spanish
  Locale('de', 'DE'), // German
];

/// Map of language codes to their display names
const Map<String, String> languageNames = {
  'en': 'English',
  'es': 'Español',
  'de': 'Deutsch',
};

/// Current locale provider
@riverpod
Locale currentLocale(CurrentLocaleRef ref) {
  final settingsAsync = ref.watch(settingsProvider);

  return settingsAsync.when(
    data: (settings) {
      // Find the locale that matches the settings language
      final locale = supportedLocales.firstWhere(
        (locale) => locale.languageCode == settings.language,
        orElse: () => supportedLocales.first, // Default to English
      );
      return locale;
    },
    loading: () => supportedLocales.first, // Default to English while loading
    error: (_, __) => supportedLocales.first, // Default to English on error
  );
}

/// Locale switcher provider for changing the app language
@riverpod
class LocaleSwitcher extends _$LocaleSwitcher {
  @override
  String build() {
    // Return the current language code
    final settingsAsync = ref.watch(settingsProvider);
    return settingsAsync.when(
      data: (settings) => settings.language,
      loading: () => 'en',
      error: (_, __) => 'en',
    );
  }

  /// Change the app language
  Future<void> changeLanguage(String languageCode) async {
    // Validate that the language is supported
    if (!supportedLocales.any((locale) => locale.languageCode == languageCode)) {
      throw ArgumentError('Unsupported language code: $languageCode');
    }

    // Update the language in settings
    try {
      await ref.read(settingsProvider.notifier).setLanguage(languageCode);
      state = languageCode;
    } catch (e) {
      // Handle error if needed
      rethrow;
    }
  }

  /// Get the display name for a language code
  String getLanguageDisplayName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }

  /// Get all supported language codes
  List<String> getSupportedLanguageCodes() {
    return supportedLocales.map((locale) => locale.languageCode).toList();
  }

  /// Check if a language code is supported
  bool isLanguageSupported(String languageCode) {
    return supportedLocales.any((locale) => locale.languageCode == languageCode);
  }

  /// Check if the current language is RTL (Right-to-Left)
  bool isRTL(String languageCode) {
    // RTL languages (prepared for future support)
    const rtlLanguages = ['ar', 'he', 'fa', 'ur'];
    return rtlLanguages.contains(languageCode);
  }

  /// Get text direction for the current language
  TextDirection getTextDirection(String languageCode) {
    return isRTL(languageCode) ? TextDirection.rtl : TextDirection.ltr;
  }
}

/// Provider for locale resolution delegates
@riverpod
List<LocalizationsDelegate> localizationDelegates(LocalizationDelegatesRef ref) {
  return const [
    // Add your app's localization delegate here when generated
    // AppLocalizations.delegate,

    // Built-in Flutter delegates
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

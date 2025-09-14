import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LocalizationUtils {
  /// Format currency amount based on locale and currency code
  static String formatCurrency(
    double amount,
    String currencyCode,
    Locale locale, {
    bool showCents = true,
  }) {
    try {
      final formatter = NumberFormat.currency(
        locale: locale.toString(),
        symbol: _getCurrencySymbol(currencyCode),
        decimalDigits: showCents ? 2 : 0,
      );
      return formatter.format(amount);
    } catch (e) {
      // Fallback to simple formatting if locale-specific formatting fails
      final symbol = _getCurrencySymbol(currencyCode);
      if (showCents) {
        return '$symbol${amount.toStringAsFixed(2)}';
      } else {
        return '$symbol${amount.toStringAsFixed(0)}';
      }
    }
  }

  /// Format date based on locale
  static String formatDate(DateTime date, Locale locale) {
    try {
      final formatter = DateFormat.yMd(locale.toString());
      return formatter.format(date);
    } catch (e) {
      // Fallback to default format
      return DateFormat.yMd().format(date);
    }
  }

  /// Format date and time based on locale
  static String formatDateTime(DateTime dateTime, Locale locale) {
    try {
      final formatter = DateFormat.yMd(locale.toString()).add_jm();
      return formatter.format(dateTime);
    } catch (e) {
      // Fallback to default format
      return DateFormat.yMd().add_jm().format(dateTime);
    }
  }

  /// Format time based on locale
  static String formatTime(DateTime time, Locale locale) {
    try {
      final formatter = DateFormat.jm(locale.toString());
      return formatter.format(time);
    } catch (e) {
      // Fallback to default format
      return DateFormat.jm().format(time);
    }
  }

  /// Format month and year based on locale
  static String formatMonthYear(DateTime date, Locale locale) {
    try {
      final formatter = DateFormat.yMMM(locale.toString());
      return formatter.format(date);
    } catch (e) {
      // Fallback to default format
      return DateFormat.yMMM().format(date);
    }
  }

  /// Format full date based on locale (e.g., "Monday, January 1, 2024")
  static String formatFullDate(DateTime date, Locale locale) {
    try {
      final formatter = DateFormat.yMMMMEEEEd(locale.toString());
      return formatter.format(date);
    } catch (e) {
      // Fallback to default format
      return DateFormat.yMMMMEEEEd().format(date);
    }
  }

  /// Format number based on locale
  static String formatNumber(num number, Locale locale) {
    try {
      final formatter = NumberFormat('#,##0', locale.toString());
      return formatter.format(number);
    } catch (e) {
      // Fallback to default format
      return NumberFormat('#,##0').format(number);
    }
  }

  /// Format percentage based on locale
  static String formatPercentage(double value, Locale locale) {
    try {
      final formatter = NumberFormat.percentPattern(locale.toString());
      return formatter.format(value);
    } catch (e) {
      // Fallback to default format
      return NumberFormat.percentPattern().format(value);
    }
  }

  /// Get currency symbol for currency code
  static String _getCurrencySymbol(String currencyCode) {
    const currencySymbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'CAD': 'C\$',
      'AUD': 'A\$',
      'CHF': 'CHF',
      'CNY': '¥',
      'INR': '₹',
      'KRW': '₩',
      'SEK': 'kr',
      'NOK': 'kr',
      'DKK': 'kr',
      'PLN': 'zł',
      'CZK': 'Kč',
      'HUF': 'Ft',
      'RUB': '₽',
      'BRL': 'R\$',
      'MXN': '\$',
      'ARS': '\$',
    };

    return currencySymbols[currencyCode] ?? currencyCode;
  }

  /// Get localized currency name
  static String getCurrencyName(String currencyCode, Locale locale) {
    const currencyNames = {
      'en': {
        'USD': 'US Dollar',
        'EUR': 'Euro',
        'GBP': 'British Pound',
        'JPY': 'Japanese Yen',
        'CAD': 'Canadian Dollar',
        'AUD': 'Australian Dollar',
        'CHF': 'Swiss Franc',
        'CNY': 'Chinese Yuan',
        'INR': 'Indian Rupee',
        'KRW': 'South Korean Won',
        'SEK': 'Swedish Krona',
        'NOK': 'Norwegian Krone',
        'DKK': 'Danish Krone',
        'PLN': 'Polish Zloty',
        'CZK': 'Czech Koruna',
        'HUF': 'Hungarian Forint',
        'RUB': 'Russian Ruble',
        'BRL': 'Brazilian Real',
        'MXN': 'Mexican Peso',
        'ARS': 'Argentine Peso',
      },
      'es': {
        'USD': 'Dólar Estadounidense',
        'EUR': 'Euro',
        'GBP': 'Libra Esterlina',
        'JPY': 'Yen Japonés',
        'CAD': 'Dólar Canadiense',
        'AUD': 'Dólar Australiano',
        'CHF': 'Franco Suizo',
        'CNY': 'Yuan Chino',
        'INR': 'Rupia India',
        'KRW': 'Won Surcoreano',
        'SEK': 'Corona Sueca',
        'NOK': 'Corona Noruega',
        'DKK': 'Corona Danesa',
        'PLN': 'Zloty Polaco',
        'CZK': 'Corona Checa',
        'HUF': 'Florín Húngaro',
        'RUB': 'Rublo Ruso',
        'BRL': 'Real Brasileño',
        'MXN': 'Peso Mexicano',
        'ARS': 'Peso Argentino',
      },
      'de': {
        'USD': 'US-Dollar',
        'EUR': 'Euro',
        'GBP': 'Britisches Pfund',
        'JPY': 'Japanischer Yen',
        'CAD': 'Kanadischer Dollar',
        'AUD': 'Australischer Dollar',
        'CHF': 'Schweizer Franken',
        'CNY': 'Chinesischer Yuan',
        'INR': 'Indische Rupie',
        'KRW': 'Südkoreanischer Won',
        'SEK': 'Schwedische Krone',
        'NOK': 'Norwegische Krone',
        'DKK': 'Dänische Krone',
        'PLN': 'Polnischer Zloty',
        'CZK': 'Tschechische Krone',
        'HUF': 'Ungarischer Forint',
        'RUB': 'Russischer Rubel',
        'BRL': 'Brasilianischer Real',
        'MXN': 'Mexikanischer Peso',
        'ARS': 'Argentinischer Peso',
      },
    };

    final languageCode = locale.languageCode;
    final names = currencyNames[languageCode] ?? currencyNames['en']!;
    return names[currencyCode] ?? currencyCode;
  }

  /// Get relative time string (e.g., "2 hours ago", "yesterday")
  static String getRelativeTime(DateTime dateTime, Locale locale) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return formatDate(dateTime, locale);
    } else if (difference.inDays >= 2) {
      return _getLocalizedString('daysAgo', locale, difference.inDays);
    } else if (difference.inDays >= 1) {
      return _getLocalizedString('yesterday', locale);
    } else if (difference.inHours >= 2) {
      return _getLocalizedString('hoursAgo', locale, difference.inHours);
    } else if (difference.inHours >= 1) {
      return _getLocalizedString('oneHourAgo', locale);
    } else if (difference.inMinutes >= 2) {
      return _getLocalizedString('minutesAgo', locale, difference.inMinutes);
    } else if (difference.inMinutes >= 1) {
      return _getLocalizedString('oneMinuteAgo', locale);
    } else {
      return _getLocalizedString('justNow', locale);
    }
  }

  /// Helper method to get localized strings for relative time
  static String _getLocalizedString(String key, Locale locale, [int? value]) {
    const strings = {
      'en': {
        'daysAgo': 'days ago',
        'yesterday': 'yesterday',
        'hoursAgo': 'hours ago',
        'oneHourAgo': '1 hour ago',
        'minutesAgo': 'minutes ago',
        'oneMinuteAgo': '1 minute ago',
        'justNow': 'just now',
      },
      'es': {
        'daysAgo': 'días atrás',
        'yesterday': 'ayer',
        'hoursAgo': 'horas atrás',
        'oneHourAgo': 'hace 1 hora',
        'minutesAgo': 'minutos atrás',
        'oneMinuteAgo': 'hace 1 minuto',
        'justNow': 'ahora mismo',
      },
      'de': {
        'daysAgo': 'Tage her',
        'yesterday': 'gestern',
        'hoursAgo': 'Stunden her',
        'oneHourAgo': 'vor 1 Stunde',
        'minutesAgo': 'Minuten her',
        'oneMinuteAgo': 'vor 1 Minute',
        'justNow': 'gerade eben',
      },
    };

    final languageCode = locale.languageCode;
    final localizedStrings = strings[languageCode] ?? strings['en']!;
    final template = localizedStrings[key] ?? key;

    if (value != null && (key == 'daysAgo' || key == 'hoursAgo' || key == 'minutesAgo')) {
      return '$value $template';
    }

    return template;
  }

  /// Get first day of week for locale (0 = Sunday, 1 = Monday)
  static int getFirstDayOfWeek(Locale locale) {
    // Most European countries start week on Monday
    if (locale.languageCode == 'de' ||
        locale.languageCode == 'es' ||
        locale.languageCode == 'fr' ||
        locale.languageCode == 'it') {
      return 1; // Monday
    }

    // US, Canada, and some others start on Sunday
    return 0; // Sunday
  }

  /// Check if locale uses 24-hour time format
  static bool uses24HourFormat(Locale locale) {
    // Most European countries use 24-hour format
    return locale.languageCode != 'en';
  }
}
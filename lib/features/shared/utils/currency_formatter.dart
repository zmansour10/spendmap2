import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _compactCurrencyFormat = NumberFormat.compactCurrency(
    symbol: '\$',
    decimalDigits: 2,
  );

  /// Format amount as currency (e.g., "$123.45")
  static String format(double amount) {
    return _currencyFormat.format(amount);
  }

  /// Format amount as compact currency (e.g., "$1.2K", "$1.5M")
  static String formatCompact(double amount) {
    return _compactCurrencyFormat.format(amount);
  }

  /// Format amount without currency symbol
  static String formatNumber(double amount) {
    return NumberFormat('#,##0.00').format(amount);
  }

  /// Parse currency string to double
  static double? parse(String currencyString) {
    try {
      // Remove currency symbol and any other non-numeric characters except decimal point
      final cleanString = currencyString
          .replaceAll(RegExp(r'[^\d.]'), '')
          .trim();
      
      if (cleanString.isEmpty) return null;
      
      return double.parse(cleanString);
    } catch (e) {
      return null;
    }
  }

  /// Check if string is a valid currency format
  static bool isValid(String currencyString) {
    return parse(currencyString) != null;
  }

  /// Format amount with custom settings
  static String formatCustom({
    required double amount,
    String symbol = '\$',
    int decimalDigits = 2,
    bool showSymbol = true,
  }) {
    final format = NumberFormat.currency(
      symbol: showSymbol ? symbol : '',
      decimalDigits: decimalDigits,
    );
    return format.format(amount);
  }
}
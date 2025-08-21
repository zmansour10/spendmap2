class AppConstants {
  // App Information
  static const String appName = 'SpendMap';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'spendmap.db';
  static const int databaseVersion = 1;
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // Border Radius
  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 12.0;
  static const double radiusXL = 16.0;
  static const double radiusXXL = 24.0;
  
  // Icon Sizes
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;
  
  // Breakpoints for Responsive Design
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;
  
  // Default Values
  static const String defaultCurrency = 'USD';
  static const String defaultLanguage = 'en';
  
  // Limits
  static const int maxDescriptionLength = 200;
  static const int maxCategoryNameLength = 50;
  static const double maxExpenseAmount = 999999.99;
  static const double minExpenseAmount = 0.01;
  
  // Date Formats
  static const String dateFormat = 'yyyy-MM-dd';
  static const String displayDateFormat = 'MMM dd, yyyy';
  static const String monthYearFormat = 'MMM yyyy';
  
  // SharedPreferences Keys
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language_code';
  static const String currencyKey = 'currency_code';
  static const String defaultCategoryKey = 'default_category_id';
  static const String firstLaunchKey = 'first_launch';
}
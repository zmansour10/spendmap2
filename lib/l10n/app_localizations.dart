import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'SpendMap'**
  String get appTitle;

  /// Label for expenses section
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// Label for categories section
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Label for statistics section
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Label for settings section
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Button text to add new expense
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// Button text to edit expense
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpense;

  /// Button text to delete expense
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get deleteExpense;

  /// Label for amount field
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Label for description field
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Label for date field
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Label for category field
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Label for currency setting
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// Label for language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Label for theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// Description for system theme
  ///
  /// In en, this message translates to:
  /// **'Follow device setting'**
  String get followDeviceSetting;

  /// Description for light theme
  ///
  /// In en, this message translates to:
  /// **'Always use light theme'**
  String get alwaysUseLightTheme;

  /// Description for dark theme
  ///
  /// In en, this message translates to:
  /// **'Always use dark theme'**
  String get alwaysUseDarkTheme;

  /// Title for currency selection
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// Title for language selection
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Title for theme selection
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// Title for category selection
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// Title for default category selection
  ///
  /// In en, this message translates to:
  /// **'Select Default Category'**
  String get selectDefaultCategory;

  /// Label for default category setting
  ///
  /// In en, this message translates to:
  /// **'Default category'**
  String get defaultCategory;

  /// Text when no category is selected
  ///
  /// In en, this message translates to:
  /// **'None selected'**
  String get noneSelected;

  /// Option for no selection
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// Section title for app preferences
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// Section title for display settings
  ///
  /// In en, this message translates to:
  /// **'Display Settings'**
  String get displaySettings;

  /// Section title for notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Section title for privacy and security
  ///
  /// In en, this message translates to:
  /// **'Privacy & Security'**
  String get privacyAndSecurity;

  /// Section title for data management
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// Section title for advanced settings
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// Section title for about information
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Setting to display amounts with decimal places
  ///
  /// In en, this message translates to:
  /// **'Show cents in amounts'**
  String get showCentsInAmounts;

  /// Description for show cents setting
  ///
  /// In en, this message translates to:
  /// **'Display amounts with decimal places'**
  String get displayAmountsWithDecimalPlaces;

  /// Setting for compact layout
  ///
  /// In en, this message translates to:
  /// **'Compact expense view'**
  String get compactExpenseView;

  /// Description for compact view setting
  ///
  /// In en, this message translates to:
  /// **'Use compact layout for expense lists'**
  String get useCompactLayoutForExpenseLists;

  /// Setting to show category labels
  ///
  /// In en, this message translates to:
  /// **'Show expense categories'**
  String get showExpenseCategories;

  /// Description for show categories setting
  ///
  /// In en, this message translates to:
  /// **'Display category labels in expense lists'**
  String get displayCategoryLabelsInExpenseLists;

  /// Setting to enable notifications
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// Description for notifications setting
  ///
  /// In en, this message translates to:
  /// **'Receive app notifications'**
  String get receiveAppNotifications;

  /// Setting for daily reminders
  ///
  /// In en, this message translates to:
  /// **'Daily spending reminders'**
  String get dailySpendingReminders;

  /// Description for daily reminders
  ///
  /// In en, this message translates to:
  /// **'Get reminded to track daily expenses'**
  String get getRemindedToTrackDailyExpenses;

  /// Setting for budget alerts
  ///
  /// In en, this message translates to:
  /// **'Budget alerts'**
  String get budgetAlerts;

  /// Description for budget alerts
  ///
  /// In en, this message translates to:
  /// **'Get notified when approaching budget limits'**
  String get getNotifiedWhenApproachingBudgetLimits;

  /// Setting for biometric authentication
  ///
  /// In en, this message translates to:
  /// **'Require biometric authentication'**
  String get requireBiometricAuthentication;

  /// Description for biometric authentication
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face unlock'**
  String get useFingerprintOrFaceUnlock;

  /// Setting to hide amounts in app switcher
  ///
  /// In en, this message translates to:
  /// **'Hide amounts in recents'**
  String get hideAmountsInRecents;

  /// Description for hide amounts setting
  ///
  /// In en, this message translates to:
  /// **'Hide expense amounts in app switcher'**
  String get hideExpenseAmountsInAppSwitcher;

  /// Setting for automatic backup
  ///
  /// In en, this message translates to:
  /// **'Auto backup'**
  String get autoBackup;

  /// Description for backup frequency
  ///
  /// In en, this message translates to:
  /// **'Backup every {days} days'**
  String backupEveryNDays(int days);

  /// Label for last backup date
  ///
  /// In en, this message translates to:
  /// **'Last backup'**
  String get lastBackup;

  /// Option to export data
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get exportData;

  /// Description for data export
  ///
  /// In en, this message translates to:
  /// **'Export all expenses and settings'**
  String get exportAllExpensesAndSettings;

  /// Option to import data
  ///
  /// In en, this message translates to:
  /// **'Import data'**
  String get importData;

  /// Description for data import
  ///
  /// In en, this message translates to:
  /// **'Import from backup file'**
  String get importFromBackupFile;

  /// Option to clear all data
  ///
  /// In en, this message translates to:
  /// **'Clear all data'**
  String get clearAllData;

  /// Description for clear data option
  ///
  /// In en, this message translates to:
  /// **'Delete all expenses and reset settings'**
  String get deleteAllExpensesAndResetSettings;

  /// Setting for delete confirmation
  ///
  /// In en, this message translates to:
  /// **'Confirm before deleting'**
  String get confirmBeforeDeleting;

  /// Description for delete confirmation setting
  ///
  /// In en, this message translates to:
  /// **'Ask for confirmation when deleting expenses'**
  String get askForConfirmationWhenDeletingExpenses;

  /// Option to reset settings
  ///
  /// In en, this message translates to:
  /// **'Reset all settings'**
  String get resetAllSettings;

  /// Description for reset settings option
  ///
  /// In en, this message translates to:
  /// **'Restore default settings (cannot be undone)'**
  String get restoreDefaultSettingsCannotBeUndone;

  /// Label for app version
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// Label for creation date
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// Label for last update date
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// Option to export as CSV
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get exportAsCSV;

  /// Description for CSV export
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet format for expenses only'**
  String get spreadsheetFormatForExpensesOnly;

  /// Option to export as JSON
  ///
  /// In en, this message translates to:
  /// **'Export as JSON'**
  String get exportAsJSON;

  /// Description for JSON export
  ///
  /// In en, this message translates to:
  /// **'Complete backup including settings'**
  String get completeBackupIncludingSettings;

  /// Button to select file
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// Dialog title for reset settings
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettings;

  /// Confirmation message for reset settings
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings to their default values? This action cannot be undone.'**
  String get resetSettingsConfirmation;

  /// Reset button text
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Confirmation message for clearing all data
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all your expenses and reset all settings to defaults. This action cannot be undone.\n\nAre you sure you want to continue?'**
  String get clearAllDataConfirmation;

  /// Clear data button text
  ///
  /// In en, this message translates to:
  /// **'Clear Data'**
  String get clearData;

  /// Title for final confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Final Confirmation'**
  String get finalConfirmation;

  /// Instruction for final deletion confirmation
  ///
  /// In en, this message translates to:
  /// **'Type \"DELETE\" to confirm data deletion:'**
  String get typeDeleteToConfirm;

  /// Success message for data export
  ///
  /// In en, this message translates to:
  /// **'Data exported to Documents/{filename}'**
  String dataExportedToDocuments(String filename);

  /// Button to show file path
  ///
  /// In en, this message translates to:
  /// **'Show Path'**
  String get showPath;

  /// Error message for export failure
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// Success message for data import
  ///
  /// In en, this message translates to:
  /// **'Data imported successfully'**
  String get dataImportedSuccessfully;

  /// Error message for import format failure
  ///
  /// In en, this message translates to:
  /// **'Import failed. Please check the file format.'**
  String get importFailedCheckFileFormat;

  /// Error message for import failure
  ///
  /// In en, this message translates to:
  /// **'Import failed: {error}'**
  String importFailed(String error);

  /// Success message for data clearing
  ///
  /// In en, this message translates to:
  /// **'All data cleared successfully'**
  String get allDataClearedSuccessfully;

  /// Error message for data clearing failure
  ///
  /// In en, this message translates to:
  /// **'Failed to clear data: {error}'**
  String failedToClearData(String error);

  /// Success message for settings reset
  ///
  /// In en, this message translates to:
  /// **'Settings reset successfully'**
  String get settingsResetSuccessfully;

  /// Error message for settings reset failure
  ///
  /// In en, this message translates to:
  /// **'Error resetting settings: {error}'**
  String errorResettingSettings(String error);

  /// Error message for settings loading failure
  ///
  /// In en, this message translates to:
  /// **'Error loading settings: {error}'**
  String errorLoadingSettings(String error);

  /// Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Warning message for language changes
  ///
  /// In en, this message translates to:
  /// **'App restart may be required for language changes to take full effect.'**
  String get appRestartMayBeRequired;

  /// Loading message for categories
  ///
  /// In en, this message translates to:
  /// **'Loading categories...'**
  String get loadingCategories;

  /// Error message for categories loading failure
  ///
  /// In en, this message translates to:
  /// **'Error loading categories: {error}'**
  String errorLoadingCategories(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

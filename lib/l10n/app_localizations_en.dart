// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SpendMap';

  @override
  String get expenses => 'Expenses';

  @override
  String get categories => 'Categories';

  @override
  String get statistics => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get editExpense => 'Edit Expense';

  @override
  String get deleteExpense => 'Delete Expense';

  @override
  String get amount => 'Amount';

  @override
  String get description => 'Description';

  @override
  String get date => 'Date';

  @override
  String get category => 'Category';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get currency => 'Currency';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'System';

  @override
  String get followDeviceSetting => 'Follow device setting';

  @override
  String get alwaysUseLightTheme => 'Always use light theme';

  @override
  String get alwaysUseDarkTheme => 'Always use dark theme';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get selectDefaultCategory => 'Select Default Category';

  @override
  String get defaultCategory => 'Default category';

  @override
  String get noneSelected => 'None selected';

  @override
  String get none => 'None';

  @override
  String get appPreferences => 'App Preferences';

  @override
  String get displaySettings => 'Display Settings';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacyAndSecurity => 'Privacy & Security';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get advanced => 'Advanced';

  @override
  String get about => 'About';

  @override
  String get showCentsInAmounts => 'Show cents in amounts';

  @override
  String get displayAmountsWithDecimalPlaces =>
      'Display amounts with decimal places';

  @override
  String get compactExpenseView => 'Compact expense view';

  @override
  String get useCompactLayoutForExpenseLists =>
      'Use compact layout for expense lists';

  @override
  String get showExpenseCategories => 'Show expense categories';

  @override
  String get displayCategoryLabelsInExpenseLists =>
      'Display category labels in expense lists';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get receiveAppNotifications => 'Receive app notifications';

  @override
  String get dailySpendingReminders => 'Daily spending reminders';

  @override
  String get getRemindedToTrackDailyExpenses =>
      'Get reminded to track daily expenses';

  @override
  String get budgetAlerts => 'Budget alerts';

  @override
  String get getNotifiedWhenApproachingBudgetLimits =>
      'Get notified when approaching budget limits';

  @override
  String get requireBiometricAuthentication =>
      'Require biometric authentication';

  @override
  String get useFingerprintOrFaceUnlock => 'Use fingerprint or face unlock';

  @override
  String get hideAmountsInRecents => 'Hide amounts in recents';

  @override
  String get hideExpenseAmountsInAppSwitcher =>
      'Hide expense amounts in app switcher';

  @override
  String get autoBackup => 'Auto backup';

  @override
  String backupEveryNDays(int days) {
    return 'Backup every $days days';
  }

  @override
  String get lastBackup => 'Last backup';

  @override
  String get exportData => 'Export data';

  @override
  String get exportAllExpensesAndSettings => 'Export all expenses and settings';

  @override
  String get importData => 'Import data';

  @override
  String get importFromBackupFile => 'Import from backup file';

  @override
  String get clearAllData => 'Clear all data';

  @override
  String get deleteAllExpensesAndResetSettings =>
      'Delete all expenses and reset settings';

  @override
  String get confirmBeforeDeleting => 'Confirm before deleting';

  @override
  String get askForConfirmationWhenDeletingExpenses =>
      'Ask for confirmation when deleting expenses';

  @override
  String get resetAllSettings => 'Reset all settings';

  @override
  String get restoreDefaultSettingsCannotBeUndone =>
      'Restore default settings (cannot be undone)';

  @override
  String get appVersion => 'App Version';

  @override
  String get created => 'Created';

  @override
  String get lastUpdated => 'Last Updated';

  @override
  String get exportAsCSV => 'Export as CSV';

  @override
  String get spreadsheetFormatForExpensesOnly =>
      'Spreadsheet format for expenses only';

  @override
  String get exportAsJSON => 'Export as JSON';

  @override
  String get completeBackupIncludingSettings =>
      'Complete backup including settings';

  @override
  String get selectFile => 'Select File';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get resetSettingsConfirmation =>
      'Are you sure you want to reset all settings to their default values? This action cannot be undone.';

  @override
  String get reset => 'Reset';

  @override
  String get clearAllDataConfirmation =>
      'This will permanently delete all your expenses and reset all settings to defaults. This action cannot be undone.\n\nAre you sure you want to continue?';

  @override
  String get clearData => 'Clear Data';

  @override
  String get finalConfirmation => 'Final Confirmation';

  @override
  String get typeDeleteToConfirm => 'Type \"DELETE\" to confirm data deletion:';

  @override
  String dataExportedToDocuments(String filename) {
    return 'Data exported to Documents/$filename';
  }

  @override
  String get showPath => 'Show Path';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get dataImportedSuccessfully => 'Data imported successfully';

  @override
  String get importFailedCheckFileFormat =>
      'Import failed. Please check the file format.';

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get allDataClearedSuccessfully => 'All data cleared successfully';

  @override
  String failedToClearData(String error) {
    return 'Failed to clear data: $error';
  }

  @override
  String get settingsResetSuccessfully => 'Settings reset successfully';

  @override
  String errorResettingSettings(String error) {
    return 'Error resetting settings: $error';
  }

  @override
  String errorLoadingSettings(String error) {
    return 'Error loading settings: $error';
  }

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get appRestartMayBeRequired =>
      'App restart may be required for language changes to take full effect.';

  @override
  String get loadingCategories => 'Loading categories...';

  @override
  String errorLoadingCategories(String error) {
    return 'Error loading categories: $error';
  }
}

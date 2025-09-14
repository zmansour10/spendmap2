// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'SpendMap';

  @override
  String get expenses => 'Ausgaben';

  @override
  String get categories => 'Kategorien';

  @override
  String get statistics => 'Statistiken';

  @override
  String get settings => 'Einstellungen';

  @override
  String get addExpense => 'Ausgabe Hinzufügen';

  @override
  String get editExpense => 'Ausgabe Bearbeiten';

  @override
  String get deleteExpense => 'Ausgabe Löschen';

  @override
  String get amount => 'Betrag';

  @override
  String get description => 'Beschreibung';

  @override
  String get date => 'Datum';

  @override
  String get category => 'Kategorie';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get currency => 'Währung';

  @override
  String get language => 'Sprache';

  @override
  String get theme => 'Design';

  @override
  String get lightTheme => 'Hell';

  @override
  String get darkTheme => 'Dunkel';

  @override
  String get systemTheme => 'System';

  @override
  String get followDeviceSetting => 'Geräteeinstellung folgen';

  @override
  String get alwaysUseLightTheme => 'Immer helles Design verwenden';

  @override
  String get alwaysUseDarkTheme => 'Immer dunkles Design verwenden';

  @override
  String get selectCurrency => 'Währung Auswählen';

  @override
  String get selectLanguage => 'Sprache Auswählen';

  @override
  String get selectTheme => 'Design Auswählen';

  @override
  String get selectCategory => 'Kategorie Auswählen';

  @override
  String get selectDefaultCategory => 'Standardkategorie Auswählen';

  @override
  String get defaultCategory => 'Standardkategorie';

  @override
  String get noneSelected => 'Keine ausgewählt';

  @override
  String get none => 'Keine';

  @override
  String get appPreferences => 'App-Einstellungen';

  @override
  String get displaySettings => 'Anzeige-Einstellungen';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get privacyAndSecurity => 'Datenschutz & Sicherheit';

  @override
  String get dataManagement => 'Daten-Management';

  @override
  String get advanced => 'Erweitert';

  @override
  String get about => 'Über';

  @override
  String get showCentsInAmounts => 'Cents in Beträgen anzeigen';

  @override
  String get displayAmountsWithDecimalPlaces =>
      'Beträge mit Dezimalstellen anzeigen';

  @override
  String get compactExpenseView => 'Kompakte Ausgabenansicht';

  @override
  String get useCompactLayoutForExpenseLists =>
      'Kompaktes Layout für Ausgabenlisten verwenden';

  @override
  String get showExpenseCategories => 'Ausgabenkategorien anzeigen';

  @override
  String get displayCategoryLabelsInExpenseLists =>
      'Kategorie-Labels in Ausgabenlisten anzeigen';

  @override
  String get enableNotifications => 'Benachrichtigungen aktivieren';

  @override
  String get receiveAppNotifications => 'App-Benachrichtigungen erhalten';

  @override
  String get dailySpendingReminders => 'Tägliche Ausgaben-Erinnerungen';

  @override
  String get getRemindedToTrackDailyExpenses =>
      'Erinnerungen für tägliche Ausgabenverfolgung erhalten';

  @override
  String get budgetAlerts => 'Budget-Warnungen';

  @override
  String get getNotifiedWhenApproachingBudgetLimits =>
      'Benachrichtigung bei Annäherung an Budget-Limits erhalten';

  @override
  String get requireBiometricAuthentication =>
      'Biometrische Authentifizierung erforderlich';

  @override
  String get useFingerprintOrFaceUnlock =>
      'Fingerabdruck oder Gesichtserkennung verwenden';

  @override
  String get hideAmountsInRecents => 'Beträge in letzten Apps ausblenden';

  @override
  String get hideExpenseAmountsInAppSwitcher =>
      'Ausgabenbeträge im App-Umschalter ausblenden';

  @override
  String get autoBackup => 'Automatisches Backup';

  @override
  String backupEveryNDays(int days) {
    return 'Backup alle $days Tage';
  }

  @override
  String get lastBackup => 'Letztes Backup';

  @override
  String get exportData => 'Daten exportieren';

  @override
  String get exportAllExpensesAndSettings =>
      'Alle Ausgaben und Einstellungen exportieren';

  @override
  String get importData => 'Daten importieren';

  @override
  String get importFromBackupFile => 'Aus Backup-Datei importieren';

  @override
  String get clearAllData => 'Alle Daten löschen';

  @override
  String get deleteAllExpensesAndResetSettings =>
      'Alle Ausgaben löschen und Einstellungen zurücksetzen';

  @override
  String get confirmBeforeDeleting => 'Vor dem Löschen bestätigen';

  @override
  String get askForConfirmationWhenDeletingExpenses =>
      'Bestätigung beim Löschen von Ausgaben erfragen';

  @override
  String get resetAllSettings => 'Alle Einstellungen zurücksetzen';

  @override
  String get restoreDefaultSettingsCannotBeUndone =>
      'Standardeinstellungen wiederherstellen (kann nicht rückgängig gemacht werden)';

  @override
  String get appVersion => 'App-Version';

  @override
  String get created => 'Erstellt';

  @override
  String get lastUpdated => 'Zuletzt Aktualisiert';

  @override
  String get exportAsCSV => 'Als CSV exportieren';

  @override
  String get spreadsheetFormatForExpensesOnly =>
      'Tabellenkalkulations-Format nur für Ausgaben';

  @override
  String get exportAsJSON => 'Als JSON exportieren';

  @override
  String get completeBackupIncludingSettings =>
      'Vollständiges Backup einschließlich Einstellungen';

  @override
  String get selectFile => 'Datei Auswählen';

  @override
  String get resetSettings => 'Einstellungen Zurücksetzen';

  @override
  String get resetSettingsConfirmation =>
      'Sind Sie sicher, dass Sie alle Einstellungen auf ihre Standardwerte zurücksetzen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get clearAllDataConfirmation =>
      'Dies wird alle Ihre Ausgaben dauerhaft löschen und alle Einstellungen auf die Standardwerte zurücksetzen. Diese Aktion kann nicht rückgängig gemacht werden.\n\nSind Sie sicher, dass Sie fortfahren möchten?';

  @override
  String get clearData => 'Daten Löschen';

  @override
  String get finalConfirmation => 'Endgültige Bestätigung';

  @override
  String get typeDeleteToConfirm =>
      'Geben Sie \"DELETE\" ein, um die Datenlöschung zu bestätigen:';

  @override
  String dataExportedToDocuments(String filename) {
    return 'Daten nach Dokumente/$filename exportiert';
  }

  @override
  String get showPath => 'Pfad Anzeigen';

  @override
  String exportFailed(String error) {
    return 'Export fehlgeschlagen: $error';
  }

  @override
  String get dataImportedSuccessfully => 'Daten erfolgreich importiert';

  @override
  String get importFailedCheckFileFormat =>
      'Import fehlgeschlagen. Bitte überprüfen Sie das Dateiformat.';

  @override
  String importFailed(String error) {
    return 'Import fehlgeschlagen: $error';
  }

  @override
  String get allDataClearedSuccessfully => 'Alle Daten erfolgreich gelöscht';

  @override
  String failedToClearData(String error) {
    return 'Löschen der Daten fehlgeschlagen: $error';
  }

  @override
  String get settingsResetSuccessfully =>
      'Einstellungen erfolgreich zurückgesetzt';

  @override
  String errorResettingSettings(String error) {
    return 'Fehler beim Zurücksetzen der Einstellungen: $error';
  }

  @override
  String errorLoadingSettings(String error) {
    return 'Fehler beim Laden der Einstellungen: $error';
  }

  @override
  String get retry => 'Wiederholen';

  @override
  String get close => 'Schließen';

  @override
  String get appRestartMayBeRequired =>
      'Ein App-Neustart kann erforderlich sein, damit Sprachänderungen vollständig wirksam werden.';

  @override
  String get loadingCategories => 'Kategorien werden geladen...';

  @override
  String errorLoadingCategories(String error) {
    return 'Fehler beim Laden der Kategorien: $error';
  }
}

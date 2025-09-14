// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'SpendMap';

  @override
  String get expenses => 'Gastos';

  @override
  String get categories => 'Categorías';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get settings => 'Configuración';

  @override
  String get addExpense => 'Agregar Gasto';

  @override
  String get editExpense => 'Editar Gasto';

  @override
  String get deleteExpense => 'Eliminar Gasto';

  @override
  String get amount => 'Cantidad';

  @override
  String get description => 'Descripción';

  @override
  String get date => 'Fecha';

  @override
  String get category => 'Categoría';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get currency => 'Moneda';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get lightTheme => 'Claro';

  @override
  String get darkTheme => 'Oscuro';

  @override
  String get systemTheme => 'Sistema';

  @override
  String get followDeviceSetting => 'Seguir configuración del dispositivo';

  @override
  String get alwaysUseLightTheme => 'Usar siempre tema claro';

  @override
  String get alwaysUseDarkTheme => 'Usar siempre tema oscuro';

  @override
  String get selectCurrency => 'Seleccionar Moneda';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get selectTheme => 'Seleccionar Tema';

  @override
  String get selectCategory => 'Seleccionar Categoría';

  @override
  String get selectDefaultCategory => 'Seleccionar Categoría Predeterminada';

  @override
  String get defaultCategory => 'Categoría predeterminada';

  @override
  String get noneSelected => 'Ninguna seleccionada';

  @override
  String get none => 'Ninguna';

  @override
  String get appPreferences => 'Preferencias de la Aplicación';

  @override
  String get displaySettings => 'Configuración de Pantalla';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get privacyAndSecurity => 'Privacidad y Seguridad';

  @override
  String get dataManagement => 'Gestión de Datos';

  @override
  String get advanced => 'Avanzado';

  @override
  String get about => 'Acerca de';

  @override
  String get showCentsInAmounts => 'Mostrar centavos en cantidades';

  @override
  String get displayAmountsWithDecimalPlaces =>
      'Mostrar cantidades con decimales';

  @override
  String get compactExpenseView => 'Vista compacta de gastos';

  @override
  String get useCompactLayoutForExpenseLists =>
      'Usar diseño compacto para listas de gastos';

  @override
  String get showExpenseCategories => 'Mostrar categorías de gastos';

  @override
  String get displayCategoryLabelsInExpenseLists =>
      'Mostrar etiquetas de categorías en listas de gastos';

  @override
  String get enableNotifications => 'Habilitar notificaciones';

  @override
  String get receiveAppNotifications =>
      'Recibir notificaciones de la aplicación';

  @override
  String get dailySpendingReminders => 'Recordatorios diarios de gastos';

  @override
  String get getRemindedToTrackDailyExpenses =>
      'Recibir recordatorios para registrar gastos diarios';

  @override
  String get budgetAlerts => 'Alertas de presupuesto';

  @override
  String get getNotifiedWhenApproachingBudgetLimits =>
      'Recibir notificaciones al acercarse a los límites del presupuesto';

  @override
  String get requireBiometricAuthentication =>
      'Requerir autenticación biométrica';

  @override
  String get useFingerprintOrFaceUnlock =>
      'Usar huella dactilar o desbloqueo facial';

  @override
  String get hideAmountsInRecents => 'Ocultar cantidades en recientes';

  @override
  String get hideExpenseAmountsInAppSwitcher =>
      'Ocultar cantidades de gastos en el selector de aplicaciones';

  @override
  String get autoBackup => 'Copia de seguridad automática';

  @override
  String backupEveryNDays(int days) {
    return 'Copia de seguridad cada $days días';
  }

  @override
  String get lastBackup => 'Última copia de seguridad';

  @override
  String get exportData => 'Exportar datos';

  @override
  String get exportAllExpensesAndSettings =>
      'Exportar todos los gastos y configuraciones';

  @override
  String get importData => 'Importar datos';

  @override
  String get importFromBackupFile =>
      'Importar desde archivo de copia de seguridad';

  @override
  String get clearAllData => 'Borrar todos los datos';

  @override
  String get deleteAllExpensesAndResetSettings =>
      'Eliminar todos los gastos y restablecer configuraciones';

  @override
  String get confirmBeforeDeleting => 'Confirmar antes de eliminar';

  @override
  String get askForConfirmationWhenDeletingExpenses =>
      'Pedir confirmación al eliminar gastos';

  @override
  String get resetAllSettings => 'Restablecer todas las configuraciones';

  @override
  String get restoreDefaultSettingsCannotBeUndone =>
      'Restaurar configuraciones predeterminadas (no se puede deshacer)';

  @override
  String get appVersion => 'Versión de la Aplicación';

  @override
  String get created => 'Creado';

  @override
  String get lastUpdated => 'Última Actualización';

  @override
  String get exportAsCSV => 'Exportar como CSV';

  @override
  String get spreadsheetFormatForExpensesOnly =>
      'Formato de hoja de cálculo solo para gastos';

  @override
  String get exportAsJSON => 'Exportar como JSON';

  @override
  String get completeBackupIncludingSettings =>
      'Copia de seguridad completa incluyendo configuraciones';

  @override
  String get selectFile => 'Seleccionar Archivo';

  @override
  String get resetSettings => 'Restablecer Configuraciones';

  @override
  String get resetSettingsConfirmation =>
      '¿Está seguro de que desea restablecer todas las configuraciones a sus valores predeterminados? Esta acción no se puede deshacer.';

  @override
  String get reset => 'Restablecer';

  @override
  String get clearAllDataConfirmation =>
      'Esto eliminará permanentemente todos sus gastos y restablecerá todas las configuraciones a los valores predeterminados. Esta acción no se puede deshacer.\n\n¿Está seguro de que desea continuar?';

  @override
  String get clearData => 'Borrar Datos';

  @override
  String get finalConfirmation => 'Confirmación Final';

  @override
  String get typeDeleteToConfirm =>
      'Escriba \"DELETE\" para confirmar la eliminación de datos:';

  @override
  String dataExportedToDocuments(String filename) {
    return 'Datos exportados a Documentos/$filename';
  }

  @override
  String get showPath => 'Mostrar Ruta';

  @override
  String exportFailed(String error) {
    return 'Exportación falló: $error';
  }

  @override
  String get dataImportedSuccessfully => 'Datos importados exitosamente';

  @override
  String get importFailedCheckFileFormat =>
      'Importación falló. Por favor verifique el formato del archivo.';

  @override
  String importFailed(String error) {
    return 'Importación falló: $error';
  }

  @override
  String get allDataClearedSuccessfully =>
      'Todos los datos fueron borrados exitosamente';

  @override
  String failedToClearData(String error) {
    return 'Falló al borrar datos: $error';
  }

  @override
  String get settingsResetSuccessfully =>
      'Configuraciones restablecidas exitosamente';

  @override
  String errorResettingSettings(String error) {
    return 'Error al restablecer configuraciones: $error';
  }

  @override
  String errorLoadingSettings(String error) {
    return 'Error al cargar configuraciones: $error';
  }

  @override
  String get retry => 'Reintentar';

  @override
  String get close => 'Cerrar';

  @override
  String get appRestartMayBeRequired =>
      'Puede ser necesario reiniciar la aplicación para que los cambios de idioma surtan efecto completo.';

  @override
  String get loadingCategories => 'Cargando categorías...';

  @override
  String errorLoadingCategories(String error) {
    return 'Error al cargar categorías: $error';
  }
}

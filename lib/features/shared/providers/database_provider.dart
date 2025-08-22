import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_helper.dart';

part 'database_provider.g.dart';

// Database Helper Provider
@riverpod
DatabaseHelper databaseHelper(DatabaseHelperRef ref) {
  return DatabaseHelper.instance;
}

// Database Provider
@riverpod
Future<Database> database(DatabaseRef ref) async {
  final helper = ref.watch(databaseHelperProvider);
  return await helper.database;
}

// Database Status Provider 
@riverpod
class DatabaseStatus extends _$DatabaseStatus {
  @override
  Future<DatabaseInfo> build() async {
    final helper = ref.watch(databaseHelperProvider);
    
    try {
      // Get database instance to ensure it's initialized
      final db = await helper.database;
      
      // Get database info
      final size = await helper.getDatabaseSize();
      final isHealthy = await helper.checkIntegrity();
      
      return DatabaseInfo(
        isInitialized: true,
        isHealthy: isHealthy,
        size: size,
        path: db.path,
        version: await db.getVersion(),
      );
    } catch (e) {
      return DatabaseInfo(
        isInitialized: false,
        isHealthy: false,
        size: 0,
        path: '',
        version: 0,
        error: e.toString(),
      );
    }
  }

  // Refresh database status
  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  // Reset database
  Future<void> resetDatabase() async {
    final helper = ref.watch(databaseHelperProvider);
    await helper.reset();
    ref.invalidateSelf();
  }

  // Backup database
  Future<String> backupDatabase() async {
    final helper = ref.watch(databaseHelperProvider);
    return await helper.backup();
  }

  // Vacuum database
  Future<void> vacuumDatabase() async {
    final helper = ref.watch(databaseHelperProvider);
    await helper.vacuum();
    ref.invalidateSelf();
  }
}

// Database Info Model
class DatabaseInfo {
  final bool isInitialized;
  final bool isHealthy;
  final int size;
  final String path;
  final int version;
  final String? error;

  const DatabaseInfo({
    required this.isInitialized,
    required this.isHealthy,
    required this.size,
    required this.path,
    required this.version,
    this.error,
  });

  // Helper getters
  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get hasError => error != null;

  @override
  String toString() {
    return 'DatabaseInfo(initialized: $isInitialized, healthy: $isHealthy, size: $formattedSize, version: $version)';
  }
}

// Database Connection Test Provider
@riverpod
Future<bool> databaseConnectionTest(DatabaseConnectionTestRef ref) async {
  try {
    final helper = ref.watch(databaseHelperProvider);
    final db = await helper.database;
    
    // Test basic operations
    await db.rawQuery('SELECT 1');
    
    // Test table existence
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'"
    );
    
    // Check if required tables exist
    final tableNames = tables.map((table) => table['name'] as String).toList();
    const requiredTables = ['categories', 'expenses', 'budgets', 'settings'];
    
    for (final table in requiredTables) {
      if (!tableNames.contains(table)) {
        return false;
      }
    }
    
    return true;
  } catch (e) {
    return false;
  }
}
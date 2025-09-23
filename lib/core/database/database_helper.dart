import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';
import 'tables.dart';

/// Database helper class
/// Manages database creation, upgrades, and provides CRUD operations
/// Implements singleton pattern to ensure single database instance
class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  // Singleton pattern
  DatabaseHelper._();

  static DatabaseHelper get instance {
    _instance ??= DatabaseHelper._();
    return _instance!;
  }

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database
  /// Creates or opens the database, applies migrations if needed
  /// @return Future<Database>
  Future<Database> _initDatabase() async {
    try {

      // In-memory database
      if (Platform.environment.containsKey('FLUTTER_TEST')) {
        return await _initInMemoryDatabase();
      }

      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, AppConstants.databaseName);

      return await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        onCreate: _createDatabase,
        onUpgrade: _upgradeDatabase,
        onConfigure: _configureDatabase,
        onOpen: _onDatabaseOpened,
      );
    } catch (e) {
      throw DatabaseException('Failed to initialize database: $e');
    }
  }

  /// Configure database settings
  /// Enables foreign keys, sets journal mode, synchronous mode, cache size, and temp store
  /// @param db The database instance
  /// @return Future<void>
  Future<void> _configureDatabase(Database db) async {
    try {

      await db.execute('PRAGMA foreign_keys = ON');

      // WAL, fallback to DELETE! 
      try {
        await db.execute('PRAGMA journal_mode = WAL');
      } catch (e) {
        await db.execute('PRAGMA journal_mode = DELETE');
      }

      await db.execute('PRAGMA synchronous = NORMAL');

      await db.execute('PRAGMA cache_size = -2000');

      await db.execute('PRAGMA temp_store = MEMORY');
    } catch (e) {
      // Log the error but don't fail the database initialization
      // TODO: For a production app, you would use a proper logging framework here
    }
  }

  /// Create database schema
  /// Creates tables, indexes, and views
  /// Inserts default data
  /// @param db The database instance
  /// @param version The version of the database
  /// @return Future<void>
  Future<void> _createDatabase(Database db, int version) async {
    final Batch batch = db.batch();

    // Create all tables
    for (String statement in DatabaseTables.createTableStatements) {
      batch.execute(statement);
    }

    // Create indexes
    for (String index in DatabaseTables.createIndexes) {
      batch.execute(index);
    }

    // Create views
    for (String view in DatabaseTables.createViews) {
      batch.execute(view);
    }

    // Execute all commands
    await batch.commit(noResult: true);

    // Insert default data
    await _insertDefaultData(db);
  }

  /// Handle database upgrades
  /// Applies migrations sequentially from oldVersion to newVersion
  /// Throws DatabaseException if any migration fails
  /// @param db The database instance
  /// @param oldVersion The current version of the database
  /// @param newVersion The target version of the database
  /// @return Future<void>
  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      final migrations = DatabaseTables.migrations[version];
      if (migrations == null || migrations.isEmpty) continue;

      final batch = db.batch();
      for (final migration in migrations) {
        batch.execute(migration);
      }

      try {
        await batch.commit(noResult: true);
      } catch (e) {
        throw DatabaseException(
            'Migration to version $version failed: ${e.toString()}');
      }
    }
  }

  /// Handle database opening
  /// Verifies foreign key constraints are enabled
  /// @param db The database instance
  /// @return Future<void>
  Future<void> _onDatabaseOpened(Database db) async {
    final result = await db.rawQuery('PRAGMA foreign_keys');
    if (result.isNotEmpty && result.first['foreign_keys'] != 1) {
      throw DatabaseException('Foreign key constraints are not enabled');
    }
  }

  /// Insert default data into the database
  /// Inserts default categories and settings
  /// @param db The database instance
  /// @return Future<void>
  Future<void> _insertDefaultData(Database db) async {
    final Batch batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    // Default categories
    for (final category in DatabaseTables.defaultCategories) {
      batch.insert(DatabaseTables.categories, {
        ...category, 
        'created_at': now,
        'updated_at': now,
      });
    }

    // Default settings
    for (final setting in DatabaseTables.defaultSettings) {
      batch.insert(DatabaseTables.settings, {
        ...setting,
        'created_at': now,
        'updated_at': now,
      });
    }

    await batch.commit(noResult: true);
  }

  // * CRUD Operations *

  /// Insert a record
  /// Automatically sets created_at and updated_at timestamps
  /// @param table The table name
  /// @param data The data to insert
  /// @return Future<int> The ID of the inserted record
  Future<int> insert(String table, Map<String, dynamic> data) async {
    try {
      final db = await database;
      final now = DateTime.now().millisecondsSinceEpoch;

      final dataWithTimestamps = {
        ...data,
        'created_at': now,
        'updated_at': now,
      };

      return await db.insert(
        table,
        dataWithTimestamps,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException('Failed to insert into $table: $e');
    }
  }

  /// Update a record
  /// Automatically updates the updated_at timestamp
  /// @param table The table name
  /// @param data The data to update
  /// @param whereClause The WHERE clause to identify records
  /// @param whereArgs The arguments for the WHERE clause
  /// @return Future<int> The number of rows affected
  Future<int> update(
    String table,
    Map<String, dynamic> data,
    String whereClause,
    List<dynamic> whereArgs,
  ) async {
    try {
      final db = await database;
      final now = DateTime.now().millisecondsSinceEpoch;

      final dataWithTimestamp = {...data, 'updated_at': now};

      return await db.update(
        table,
        dataWithTimestamp,
        where: whereClause,
        whereArgs: whereArgs,
      );
    } catch (e) {
      throw DatabaseException('Failed to update $table: $e');
    }
  }

  /// Delete records
  /// @param table The table name
  /// @param whereClause The WHERE clause to identify records
  /// @param whereArgs The arguments for the WHERE clause
  /// @return Future<int> The number of rows deleted
  Future<int> delete(
    String table,
    String whereClause,
    List<dynamic> whereArgs,
  ) async {
    try {
      final db = await database;
      return await db.delete(table, where: whereClause, whereArgs: whereArgs);
    } catch (e) {
      throw DatabaseException('Failed to delete from $table: $e');
    }
  }

  /// Query records
  Future<List<Map<String, dynamic>>> query(
    String table, {
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await database;
      return await db.query(
        table,
        columns: columns,
        where: where,
        whereArgs: whereArgs,
        groupBy: groupBy,
        having: having,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw DatabaseException('Failed to query $table: $e');
    }
  }

  /// Raw query
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, 
    [List<dynamic>? arguments]) async {
    try {
      final db = await database;
      return await db.rawQuery(sql, arguments);
    } catch (e) {
      throw DatabaseException('Failed to execute raw query: $e');
    }
  }

  /// Execute raw SQL
  Future<void> execute(
    String sql, 
    [List<dynamic>? arguments]) async {
    try {
      final db = await database;
      await db.execute(sql, arguments);
    } catch (e) {
      throw DatabaseException('Failed to execute SQL: $e');
    }
  }

  /// Transactions
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    try {
      final db = await database;
      return await db.transaction(action);
    } catch (e) {
      throw DatabaseException('Transaction failed: $e');
    }
  }

  /// Batch operations
  Future<List<dynamic>> batch(void Function(Batch batch) operations) async {
    try {
      final db = await database;
      final batch = db.batch();
      operations(batch);
      return await batch.commit();
    } catch (e) {
      throw DatabaseException('Batch operation failed: $e');
    }
  }

  // * Database maintenance *

  // Get database size
  Future<int> getDatabaseSize() async {
    try {
      final db = await database;
      final path = db.path;
      final file = File(path);
      return await file.length();
    } catch (e) {
      throw DatabaseException('Failed to get database size: $e');
    }
  }

  // Vacuum database to reclaim space
  Future<void> vacuum() async {
    try {
      final db = await database;
      await db.execute('VACUUM');
    } catch (e) {
      throw DatabaseException('Failed to vacuum database: $e');
    }
  }

  // Check database integrity
  Future<bool> checkIntegrity() async {
    try {
      final db = await database;
      final result = await db.rawQuery('PRAGMA integrity_check');
      return result.isNotEmpty &&
          result.first.values.first.toString().toLowerCase() == 'ok';
    } catch (e) {
      throw DatabaseException('Failed to check database integrity: $e');
    }
  }

  /// Backup database 
  /// @return Future<String> The path to the backup file
  Future<String> backup() async {
    try {
      final db = await database;
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final backupPath = join(documentsDirectory.path, 'backup_$timestamp.db');

      final originalFile = File(db.path);
      await originalFile.copy(backupPath);

      return backupPath;
    } catch (e) {
      throw DatabaseException('Failed to backup database: $e');
    }
  }

  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Reset database
  /// Deletes the existing database file and reinitializes the database
  Future<void> reset() async {
    try {
      await close();
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final path = join(documentsDirectory.path, AppConstants.databaseName);
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }

      // Reinitialize the database
      _database = await _initDatabase();
    } catch (e) {
      throw DatabaseException('Failed to reset database: $e');
    }
  }

  /// Initialize in-memory database for testing
  /// @return Future<Database> The in-memory database instance
  Future<Database> _initInMemoryDatabase() async {
    return await openDatabase(
      ':memory:',
      version: AppConstants.databaseVersion,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
      onConfigure: _configureDatabase,
      onOpen: _onDatabaseOpened,
    );
  }
}

/// Custom Database exception for database errors
class DatabaseException implements Exception {
  final String message;

  const DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}

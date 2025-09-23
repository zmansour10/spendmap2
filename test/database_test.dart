
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:spendmap2/core/database/database_helper.dart';
import 'package:spendmap2/core/database/tables.dart';

void main() {
  group('Database Tests', () {
    late DatabaseHelper databaseHelper;

    setUpAll(() async {
      // Flutter binding for testing
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // FFI for testing SQLite
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() {
      databaseHelper = DatabaseHelper.instance;
    });

    tearDown(() async {
      await databaseHelper.close();
    });

    test('should initialize database successfully', () async {
      final db = await databaseHelper.database;
      expect(db, isNotNull);
      expect(db.isOpen, isTrue);
    });

    test('should create all required tables', () async {
      final db = await databaseHelper.database;
      
      // Check if tables exist
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table'"
      );
      
      final tableNames = tables.map((table) => table['name'] as String).toList();
      
      expect(tableNames, contains('categories'));
      expect(tableNames, contains('expenses'));
      expect(tableNames, contains('budgets'));
      expect(tableNames, contains('settings'));
    });

    test('should insert default categories', () async {
      final categories = await databaseHelper.query(DatabaseTables.categories);
      
      expect(categories.length, equals(DatabaseTables.defaultCategories.length));
      expect(categories.first['name'], equals('Food & Dining'));
    });

    test('should insert default settings', () async {
      final settings = await databaseHelper.query(DatabaseTables.settings);
      
      expect(settings.length, equals(DatabaseTables.defaultSettings.length));
      
      final currencySetting = settings.firstWhere((s) => s['key'] == 'currency');
      expect(currencySetting['value'], equals('USD'));
    });

    test('should perform CRUD operations', () async {
      // Test Insert
      final categoryId = await databaseHelper.insert(DatabaseTables.categories, {
        'name': 'Test Category',
        'icon_code': 123,
        'color': 0xFF000000,
        'is_default': 0,
        'is_active': 1,
      });
      
      expect(categoryId, greaterThan(0));
      
      // Test Query
      final categories = await databaseHelper.query(
        DatabaseTables.categories,
        where: 'id = ?',
        whereArgs: [categoryId],
      );
      
      expect(categories.length, equals(1));
      expect(categories.first['name'], equals('Test Category'));
      
      // Test Update
      final updateCount = await databaseHelper.update(
        DatabaseTables.categories,
        {'name': 'Updated Category'},
        'id = ?',
        [categoryId],
      );
      
      expect(updateCount, equals(1));
      
      // Test Delete
      final deleteCount = await databaseHelper.delete(
        DatabaseTables.categories,
        'id = ?',
        [categoryId],
      );
      
      expect(deleteCount, equals(1));
    });

    test('should check database integrity', () async {
      final isHealthy = await databaseHelper.checkIntegrity();
      expect(isHealthy, isTrue);
    });
  });
}

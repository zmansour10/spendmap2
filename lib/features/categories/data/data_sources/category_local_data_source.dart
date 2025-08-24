import '../../../../core/database/database_helper.dart';
import '../../../../core/database/tables.dart';
import '../models/category.dart';

/// Local data source for categories using SQLite
/// Handles all database operations for categories
class CategoryLocalDataSource {
  final DatabaseHelper _databaseHelper;

  const CategoryLocalDataSource(this._databaseHelper);

  /// Get all categories from database
  Future<List<Category>> getAllCategories() async {
    try {
      final result = await _databaseHelper.query(
        DatabaseTables.categories,
        orderBy: 'name ASC',
      );
      
      return result.map((map) => Category.fromDatabase(map)).toList();
    } catch (e) {
      throw CategoryDataSourceException('Failed to get all categories: $e');
    }
  }

  /// Get active categories only
  Future<List<Category>> getActiveCategories() async {
    try {
      final result = await _databaseHelper.query(
        DatabaseTables.categories,
        where: 'is_active = ?',
        whereArgs: [1],
        orderBy: 'is_default DESC, name ASC', // Default categories first
      );
      
      return result.map((map) => Category.fromDatabase(map)).toList();
    } catch (e) {
      throw CategoryDataSourceException('Failed to get active categories: $e');
    }
  }

  /// Get inactive categories only
  Future<List<Category>> getInactiveCategories() async {
    try {
      final result = await _databaseHelper.query(
        DatabaseTables.categories,
        where: 'is_active = ?',
        whereArgs: [0],
        orderBy: 'name ASC',
      );
      
      return result.map((map) => Category.fromDatabase(map)).toList();
    } catch (e) {
      throw CategoryDataSourceException('Failed to get inactive categories: $e');
    }
  }

  /// Get default categories
  Future<List<Category>> getDefaultCategories() async {
    try {
      final result = await _databaseHelper.query(
        DatabaseTables.categories,
        where: 'is_default = ?',
        whereArgs: [1],
        orderBy: 'name ASC',
      );
      
      return result.map((map) => Category.fromDatabase(map)).toList();
    } catch (e) {
      throw CategoryDataSourceException('Failed to get default categories: $e');
    }
  }

  /// Get user categories
  Future<List<Category>> getUserCategories() async {
    try {
      final result = await _databaseHelper.query(
        DatabaseTables.categories,
        where: 'is_default = ?',
        whereArgs: [0],
        orderBy: 'name ASC',
      );
      
      return result.map((map) => Category.fromDatabase(map)).toList();
    } catch (e) {
      throw CategoryDataSourceException('Failed to get user categories: $e');
    }
  }

  /// Get category by ID
  Future<Category?> getCategoryById(int id) async {
    try {
      final result = await _databaseHelper.query(
        DatabaseTables.categories,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (result.isEmpty) return null;
      return Category.fromDatabase(result.first);
    } catch (e) {
      throw CategoryDataSourceException('Failed to get category by ID: $e');
    }
  }

  /// Get category by name
  Future<Category?> getCategoryByName(String name) async {
    try {
      final result = await _databaseHelper.query(
        DatabaseTables.categories,
        where: 'LOWER(name) = LOWER(?)',
        whereArgs: [name],
        limit: 1,
      );
      
      if (result.isEmpty) return null;
      return Category.fromDatabase(result.first);
    } catch (e) {
      throw CategoryDataSourceException('Failed to get category by name: $e');
    }
  }

  /// Search categories by name
  Future<List<Category>> searchCategories(String query) async {
    try {
      final result = await _databaseHelper.query(
        DatabaseTables.categories,
        where: 'LOWER(name) LIKE LOWER(?) AND is_active = ?',
        whereArgs: ['%$query%', 1],
        orderBy: 'name ASC',
      );
      
      return result.map((map) => Category.fromDatabase(map)).toList();
    } catch (e) {
      throw CategoryDataSourceException('Failed to search categories: $e');
    }
  }

  /// Insert new category
  Future<Category> insertCategory(Category category) async {
    try {
      final id = await _databaseHelper.insert(
        DatabaseTables.categories,
        category.toDatabase(),
      );
      
      // Return category with generated ID
      return category.copyWith(id: id);
    } catch (e) {
      throw CategoryDataSourceException('Failed to insert category: $e');
    }
  }

  /// Update existing category
  Future<Category> updateCategory(Category category) async {
    try {
      if (category.id == null) {
        throw CategoryDataSourceException('Cannot update category without ID');
      }

      final updatedCategory = category.copyWith(updatedAt: DateTime.now());
      
      final rowsAffected = await _databaseHelper.update(
        DatabaseTables.categories,
        updatedCategory.toDatabase(),
        'id = ?',
        [category.id!],
      );

      if (rowsAffected == 0) {
        throw CategoryDataSourceException('Category not found for update');
      }

      return updatedCategory;
    } catch (e) {
      throw CategoryDataSourceException('Failed to update category: $e');
    }
  }

  /// Soft delete category (set inactive)
  Future<void> deleteCategory(int id) async {
    try {
      final rowsAffected = await _databaseHelper.update(
        DatabaseTables.categories,
        {
          'is_active': 0,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        'id = ?',
        [id],
      );

      if (rowsAffected == 0) {
        throw CategoryDataSourceException('Category not found for deletion');
      }
    } catch (e) {
      throw CategoryDataSourceException('Failed to delete category: $e');
    }
  }

  /// Hard delete category (permanent)
  Future<void> permanentlyDeleteCategory(int id) async {
    try {
      final rowsAffected = await _databaseHelper.delete(
        DatabaseTables.categories,
        'id = ?',
        [id],
      );

      if (rowsAffected == 0) {
        throw CategoryDataSourceException('Category not found for permanent deletion');
      }
    } catch (e) {
      throw CategoryDataSourceException('Failed to permanently delete category: $e');
    }
  }

  /// Restore deleted category
  Future<Category> restoreCategory(int id) async {
    try {
      final updatedAt = DateTime.now();
      
      final rowsAffected = await _databaseHelper.update(
        DatabaseTables.categories,
        {
          'is_active': 1,
          'updated_at': updatedAt.millisecondsSinceEpoch,
        },
        'id = ?',
        [id],
      );

      if (rowsAffected == 0) {
        throw CategoryDataSourceException('Category not found for restoration');
      }

      // Return updated category
      final category = await getCategoryById(id);
      if (category == null) {
        throw CategoryDataSourceException('Failed to retrieve restored category');
      }

      return category;
    } catch (e) {
      throw CategoryDataSourceException('Failed to restore category: $e');
    }
  }

  /// Check if category name exists
  Future<bool> categoryNameExists(String name, {int? excludeId}) async {
    try {
      String whereClause = 'LOWER(name) = LOWER(?)';
      List<dynamic> whereArgs = [name];

      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId);
      }

      final result = await _databaseHelper.query(
        DatabaseTables.categories,
        columns: ['id'],
        where: whereClause,
        whereArgs: whereArgs,
        limit: 1,
      );

      return result.isNotEmpty;
    } catch (e) {
      throw CategoryDataSourceException('Failed to check if category name exists: $e');
    }
  }

  /// Check if category has expenses
  Future<bool> categoryHasExpenses(int id) async {
    try {
      final result = await _databaseHelper.query(
        DatabaseTables.expenses,
        columns: ['id'],
        where: 'category_id = ?',
        whereArgs: [id],
        limit: 1,
      );

      return result.isNotEmpty;
    } catch (e) {
      throw CategoryDataSourceException('Failed to check if category has expenses: $e');
    }
  }

  /// Get categories count
  Future<int> getCategoriesCount({bool includeInactive = false}) async {
    try {
      String? whereClause;
      List<dynamic>? whereArgs;

      if (!includeInactive) {
        whereClause = 'is_active = ?';
        whereArgs = [1];
      }

      final result = await _databaseHelper.query(
        DatabaseTables.categories,
        columns: ['COUNT(*) as count'],
        where: whereClause,
        whereArgs: whereArgs,
      );

      return result.first['count'] as int;
    } catch (e) {
      throw CategoryDataSourceException('Failed to get categories count: $e');
    }
  }

  /// Bulk insert categories
  Future<List<Category>> bulkInsertCategories(List<Category> categories) async {
    try {
      return await _databaseHelper.transaction<List<Category>>((txn) async {
        final insertedCategories = <Category>[];
        
        for (final category in categories) {
          final id = await txn.insert(
            DatabaseTables.categories,
            category.toDatabase(),
          );
          insertedCategories.add(category.copyWith(id: id));
        }
        
        return insertedCategories;
      });
    } catch (e) {
      throw CategoryDataSourceException('Failed to bulk insert categories: $e');
    }
  }

  /// Bulk update categories
  Future<void> bulkUpdateCategories(List<Category> categories) async {
    try {
      await _databaseHelper.transaction<void>((txn) async {
        for (final category in categories) {
          if (category.id == null) continue;
          
          final updatedCategory = category.copyWith(updatedAt: DateTime.now());
          
          await txn.update(
            DatabaseTables.categories,
            updatedCategory.toDatabase(),
            where: 'id = ?',
            whereArgs: [category.id!],
          );
        }
      });
    } catch (e) {
      throw CategoryDataSourceException('Failed to bulk update categories: $e');
    }
  }

  /// Bulk delete categories
  Future<void> bulkDeleteCategories(List<int> ids) async {
    try {
      if (ids.isEmpty) return;
      
      final placeholders = List.filled(ids.length, '?').join(',');
      
      await _databaseHelper.update(
        DatabaseTables.categories,
        {
          'is_active': 0,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        'id IN ($placeholders)',
        ids,
      );
    } catch (e) {
      throw CategoryDataSourceException('Failed to bulk delete categories: $e');
    }
  }
}

/// Custom exception for category data source operations
class CategoryDataSourceException implements Exception {
  final String message;
  
  const CategoryDataSourceException(this.message);
  
  @override
  String toString() => 'CategoryDataSourceException: $message';
}
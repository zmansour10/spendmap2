import '../../../../core/database/database_helper.dart';
import '../../../../core/database/tables.dart';
import '../models/expense.dart';
import '../../domain/entities/expense_entity.dart';

/// Local data source for expenses using SQLite
class ExpenseLocalDataSource {
  final DatabaseHelper _databaseHelper;

  const ExpenseLocalDataSource(this._databaseHelper);

  /// Get all expenses
  Future<List<Expense>> getAllExpenses() async {
    try {
      final result = await _databaseHelper.query(
        DatabaseTables.expenses,
        orderBy: 'date DESC',
      );
      
      return result.map((map) => Expense.fromDatabase(map)).toList();
    } catch (e) {
      throw ExpenseDataSourceException('Failed to get all expenses: $e');
    }
  }

  /// Get expense by ID
  Future<Expense?> getExpenseById(int id) async {
    try {
      final result = await _databaseHelper.query(
        DatabaseTables.expenses,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      
      if (result.isEmpty) return null;
      return Expense.fromDatabase(result.first);
    } catch (e) {
      throw ExpenseDataSourceException('Failed to get expense by ID: $e');
    }
  }

  /// Insert new expense
  Future<Expense> insertExpense(Expense expense) async {
    try {
      final id = await _databaseHelper.insert(
        DatabaseTables.expenses,
        expense.toDatabase(),
      );
      
      return expense.copyWith(id: id);
    } catch (e) {
      throw ExpenseDataSourceException('Failed to insert expense: $e');
    }
  }

  /// Update expense
  Future<Expense> updateExpense(Expense expense) async {
    try {
      if (expense.id == null) {
        throw ExpenseDataSourceException('Cannot update expense without ID');
      }

      final updatedExpense = expense.copyWith(updatedAt: DateTime.now());
      
      final rowsAffected = await _databaseHelper.update(
        DatabaseTables.expenses,
        updatedExpense.toDatabase(),
        'id = ?',
        [expense.id!],
      );

      if (rowsAffected == 0) {
        throw ExpenseDataSourceException('Expense not found for update');
      }

      return updatedExpense;
    } catch (e) {
      throw ExpenseDataSourceException('Failed to update expense: $e');
    }
  }

  /// Delete expense
  Future<void> deleteExpense(int id) async {
    try {
      final rowsAffected = await _databaseHelper.delete(
        DatabaseTables.expenses,
        'id = ?',
        [id],
      );

      if (rowsAffected == 0) {
        throw ExpenseDataSourceException('Expense not found for deletion');
      }
    } catch (e) {
      throw ExpenseDataSourceException('Failed to delete expense: $e');
    }
  }

  /// Get expenses by date range
  Future<List<Expense>> getExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final startMillis = startDate.millisecondsSinceEpoch;
      final endMillis = endDate.millisecondsSinceEpoch;
      
      final result = await _databaseHelper.query(
        DatabaseTables.expenses,
        where: 'date >= ? AND date <= ?',
        whereArgs: [startMillis, endMillis],
        orderBy: 'date DESC',
      );
      
      return result.map((map) => Expense.fromDatabase(map)).toList();
    } catch (e) {
      throw ExpenseDataSourceException('Failed to get expenses by date range: $e');
    }
  }

  /// Get expenses by category
  Future<List<Expense>> getExpensesByCategory(int categoryId) async {
    try {
      final result = await _databaseHelper.query(
        DatabaseTables.expenses,
        where: 'category_id = ?',
        whereArgs: [categoryId],
        orderBy: 'date DESC',
      );
      
      return result.map((map) => Expense.fromDatabase(map)).toList();
    } catch (e) {
      throw ExpenseDataSourceException('Failed to get expenses by category: $e');
    }
  }

  /// Get expenses by multiple categories
  Future<List<Expense>> getExpensesByCategories(List<int> categoryIds) async {
    try {
      if (categoryIds.isEmpty) return [];
      
      final placeholders = List.filled(categoryIds.length, '?').join(',');
      final result = await _databaseHelper.query(
        DatabaseTables.expenses,
        where: 'category_id IN ($placeholders)',
        whereArgs: categoryIds,
        orderBy: 'date DESC',
      );
      
      return result.map((map) => Expense.fromDatabase(map)).toList();
    } catch (e) {
      throw ExpenseDataSourceException('Failed to get expenses by categories: $e');
    }
  }

  /// Search expenses by description or amount
  Future<List<Expense>> searchExpenses(String query) async {
    try {
      final result = await _databaseHelper.query(
        DatabaseTables.expenses,
        where: 'LOWER(description) LIKE LOWER(?) OR CAST(amount AS TEXT) LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'date DESC',
      );
      
      return result.map((map) => Expense.fromDatabase(map)).toList();
    } catch (e) {
      throw ExpenseDataSourceException('Failed to search expenses: $e');
    }
  }

  /// Get filtered expenses with complex criteria
  Future<List<Expense>> getFilteredExpenses(ExpenseFilter filter) async {
    try {
      final whereConditions = <String>[];
      final whereArgs = <dynamic>[];
      
      // Date range filter
      if (filter.startDate != null) {
        whereConditions.add('date >= ?');
        whereArgs.add(filter.startDate!.millisecondsSinceEpoch);
      }
      
      if (filter.endDate != null) {
        whereConditions.add('date <= ?');
        whereArgs.add(filter.endDate!.millisecondsSinceEpoch);
      }
      
      // Category filter
      if (filter.categoryIds != null && filter.categoryIds!.isNotEmpty) {
        final placeholders = List.filled(filter.categoryIds!.length, '?').join(',');
        whereConditions.add('category_id IN ($placeholders)');
        whereArgs.addAll(filter.categoryIds!);
      }
      
      // Amount range filter
      if (filter.minAmount != null) {
        whereConditions.add('amount >= ?');
        whereArgs.add(filter.minAmount);
      }
      
      if (filter.maxAmount != null) {
        whereConditions.add('amount <= ?');
        whereArgs.add(filter.maxAmount);
      }
      
      // Search query filter
      if (filter.searchQuery != null && filter.searchQuery!.trim().isNotEmpty) {
        whereConditions.add('(LOWER(description) LIKE LOWER(?) OR CAST(amount AS TEXT) LIKE ?)');
        final searchTerm = '%${filter.searchQuery!.trim()}%';
        whereArgs.addAll([searchTerm, searchTerm]);
      }
      
      // Build ORDER BY clause
      String orderBy = _buildOrderByClause(filter.sortOption, filter.sortAscending);
      
      final result = await _databaseHelper.query(
        DatabaseTables.expenses,
        where: whereConditions.isNotEmpty ? whereConditions.join(' AND ') : null,
       whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
       orderBy: orderBy,
     );
     
     return result.map((map) => Expense.fromDatabase(map)).toList();
   } catch (e) {
     throw ExpenseDataSourceException('Failed to get filtered expenses: $e');
   }
 }

 /// Get expenses with pagination
 Future<List<Expense>> getExpensesPaginated({
   int offset = 0,
   int limit = 20,
   ExpenseFilter? filter,
 }) async {
   try {
     final whereConditions = <String>[];
     final whereArgs = <dynamic>[];
     
     if (filter != null) {
       // Apply same filtering logic as getFilteredExpenses
       if (filter.startDate != null) {
         whereConditions.add('date >= ?');
         whereArgs.add(filter.startDate!.millisecondsSinceEpoch);
       }
       
       if (filter.endDate != null) {
         whereConditions.add('date <= ?');
         whereArgs.add(filter.endDate!.millisecondsSinceEpoch);
       }
       
       if (filter.categoryIds != null && filter.categoryIds!.isNotEmpty) {
         final placeholders = List.filled(filter.categoryIds!.length, '?').join(',');
         whereConditions.add('category_id IN ($placeholders)');
         whereArgs.addAll(filter.categoryIds!);
       }
       
       if (filter.minAmount != null) {
         whereConditions.add('amount >= ?');
         whereArgs.add(filter.minAmount);
       }
       
       if (filter.maxAmount != null) {
         whereConditions.add('amount <= ?');
         whereArgs.add(filter.maxAmount);
       }
       
       if (filter.searchQuery != null && filter.searchQuery!.trim().isNotEmpty) {
         whereConditions.add('(LOWER(description) LIKE LOWER(?) OR CAST(amount AS TEXT) LIKE ?)');
         final searchTerm = '%${filter.searchQuery!.trim()}%';
         whereArgs.addAll([searchTerm, searchTerm]);
       }
     }
     
     String orderBy = filter != null 
         ? _buildOrderByClause(filter.sortOption, filter.sortAscending)
         : 'date DESC';
     
     final result = await _databaseHelper.query(
       DatabaseTables.expenses,
       where: whereConditions.isNotEmpty ? whereConditions.join(' AND ') : null,
       whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
       orderBy: orderBy,
       limit: limit,
       offset: offset,
     );
     
     return result.map((map) => Expense.fromDatabase(map)).toList();
   } catch (e) {
     throw ExpenseDataSourceException('Failed to get paginated expenses: $e');
   }
 }

 /// Get expenses with category information (joined query)
 Future<List<ExpenseWithCategory>> getExpensesWithCategories({
   ExpenseFilter? filter,
   int? limit,
   int? offset,
 }) async {
   try {
     final whereConditions = <String>[];
     final whereArgs = <dynamic>[];
     
     if (filter != null) {
       if (filter.startDate != null) {
         whereConditions.add('e.date >= ?');
         whereArgs.add(filter.startDate!.millisecondsSinceEpoch);
       }
       
       if (filter.endDate != null) {
         whereConditions.add('e.date <= ?');
         whereArgs.add(filter.endDate!.millisecondsSinceEpoch);
       }
       
       if (filter.categoryIds != null && filter.categoryIds!.isNotEmpty) {
         final placeholders = List.filled(filter.categoryIds!.length, '?').join(',');
         whereConditions.add('e.category_id IN ($placeholders)');
         whereArgs.addAll(filter.categoryIds!);
       }
       
       if (filter.minAmount != null) {
         whereConditions.add('e.amount >= ?');
         whereArgs.add(filter.minAmount);
       }
       
       if (filter.maxAmount != null) {
         whereConditions.add('e.amount <= ?');
         whereArgs.add(filter.maxAmount);
       }
       
       if (filter.searchQuery != null && filter.searchQuery!.trim().isNotEmpty) {
         whereConditions.add('(LOWER(e.description) LIKE LOWER(?) OR CAST(e.amount AS TEXT) LIKE ?)');
         final searchTerm = '%${filter.searchQuery!.trim()}%';
         whereArgs.addAll([searchTerm, searchTerm]);
       }
     }

     // Add active category filter
     whereConditions.add('c.is_active = 1');
     whereArgs.add(1);
     
     String orderBy = filter != null 
         ? _buildOrderByClauseForJoin(filter.sortOption, filter.sortAscending)
         : 'e.date DESC';
     
     String sql = '''
       SELECT 
         e.id,
         e.amount,
         e.description,
         e.date,
         e.created_at,
         e.updated_at,
         e.category_id,
         c.name as category_name,
         c.icon_code as category_icon,
         c.color_value as category_color
       FROM ${DatabaseTables.expenses} e
       INNER JOIN ${DatabaseTables.categories} c ON e.category_id = c.id
       ${whereConditions.isNotEmpty ? 'WHERE ${whereConditions.join(' AND ')}' : ''}
       ORDER BY $orderBy
       ${limit != null ? 'LIMIT $limit' : ''}
       ${offset != null ? 'OFFSET $offset' : ''}
     ''';
     
     final result = await _databaseHelper.rawQuery(sql, whereArgs);
     
     return result.map((map) => ExpenseWithCategory.fromDatabase(map)).toList();
   } catch (e) {
     throw ExpenseDataSourceException('Failed to get expenses with categories: $e');
   }
 }

 /// Get expense with category by ID
 Future<ExpenseWithCategory?> getExpenseWithCategoryById(int id) async {
   try {
     String sql = '''
       SELECT 
         e.id,
         e.amount,
         e.description,
         e.date,
         e.created_at,
         e.updated_at,
         e.category_id,
         c.name as category_name,
         c.icon_code as category_icon,
         c.color_value as category_color
       FROM ${DatabaseTables.expenses} e
       INNER JOIN ${DatabaseTables.categories} c ON e.category_id = c.id
       WHERE e.id = ? AND c.is_active = 1
     ''';
     
     final result = await _databaseHelper.rawQuery(sql, [id]);
     
     if (result.isEmpty) return null;
     return ExpenseWithCategory.fromDatabase(result.first);
   } catch (e) {
     throw ExpenseDataSourceException('Failed to get expense with category by ID: $e');
   }
 }

 /// Get expense statistics
 Future<ExpenseStats> getExpenseStats({
   DateTime? startDate,
   DateTime? endDate,
   List<int>? categoryIds,
 }) async {
   try {
     final whereConditions = <String>[];
     final whereArgs = <dynamic>[];
     
     if (startDate != null) {
       whereConditions.add('date >= ?');
       whereArgs.add(startDate.millisecondsSinceEpoch);
     }
     
     if (endDate != null) {
       whereConditions.add('date <= ?');
       whereArgs.add(endDate.millisecondsSinceEpoch);
     }
     
     if (categoryIds != null && categoryIds.isNotEmpty) {
       final placeholders = List.filled(categoryIds.length, '?').join(',');
       whereConditions.add('category_id IN ($placeholders)');
       whereArgs.addAll(categoryIds);
     }
     
     String sql = '''
       SELECT 
         COALESCE(SUM(amount), 0) as total_amount,
         COUNT(*) as expense_count,
         COALESCE(AVG(amount), 0) as average_amount,
         COALESCE(MAX(amount), 0) as highest_amount,
         COALESCE(MIN(amount), 0) as lowest_amount
       FROM ${DatabaseTables.expenses}
       ${whereConditions.isNotEmpty ? 'WHERE ${whereConditions.join(' AND ')}' : ''}
     ''';
     
     final result = await _databaseHelper.rawQuery(sql, whereArgs);
     
     if (result.isEmpty) return ExpenseStats.empty();
     
     final row = result.first;
     return ExpenseStats(
       totalAmount: (row['total_amount'] as num).toDouble(),
       expenseCount: row['expense_count'] as int,
       averageAmount: (row['average_amount'] as num).toDouble(),
       highestAmount: (row['highest_amount'] as num).toDouble(),
       lowestAmount: (row['lowest_amount'] as num).toDouble(),
       periodStart: startDate,
       periodEnd: endDate,
     );
   } catch (e) {
     throw ExpenseDataSourceException('Failed to get expense stats: $e');
   }
 }

 /// Get category expense summary
 Future<List<CategoryExpenseSummary>> getCategoryExpenseSummary({
   DateTime? startDate,
   DateTime? endDate,
 }) async {
   try {
     final whereConditions = <String>['c.is_active = 1'];
     final whereArgs = <dynamic>[];
     
     if (startDate != null) {
       whereConditions.add('e.date >= ?');
       whereArgs.add(startDate.millisecondsSinceEpoch);
     }
     
     if (endDate != null) {
       whereConditions.add('e.date <= ?');
       whereArgs.add(endDate.millisecondsSinceEpoch);
     }
     
     String sql = '''
       WITH total_expenses AS (
         SELECT COALESCE(SUM(amount), 0) as total
         FROM ${DatabaseTables.expenses} e
         INNER JOIN ${DatabaseTables.categories} c ON e.category_id = c.id
         WHERE ${whereConditions.join(' AND ')}
       )
       SELECT 
         c.id as category_id,
         c.name as category_name,
         c.icon_code as category_icon,
         c.color_value as category_color,
         COALESCE(SUM(e.amount), 0) as total_amount,
         COUNT(e.id) as expense_count,
         COALESCE(AVG(e.amount), 0) as average_amount,
         CASE 
           WHEN total_expenses.total > 0 THEN (COALESCE(SUM(e.amount), 0) * 100.0 / total_expenses.total)
           ELSE 0
         END as percentage
       FROM ${DatabaseTables.categories} c
       LEFT JOIN ${DatabaseTables.expenses} e ON c.id = e.category_id
       CROSS JOIN total_expenses
       WHERE ${whereConditions.join(' AND ')}
       GROUP BY c.id, c.name, c.icon_code, c.color_value, total_expenses.total
       HAVING COUNT(e.id) > 0
       ORDER BY total_amount DESC
     ''';
     
     final result = await _databaseHelper.rawQuery(sql, whereArgs);
     
     return result.map((row) => CategoryExpenseSummary(
       categoryId: row['category_id'] as int,
       categoryName: row['category_name'] as String,
       categoryIcon: row['category_icon'] as int,
       categoryColor: row['category_color'] as int,
       totalAmount: (row['total_amount'] as num).toDouble(),
       expenseCount: row['expense_count'] as int,
       averageAmount: (row['average_amount'] as num).toDouble(),
       percentage: (row['percentage'] as num).toDouble(),
     )).toList();
   } catch (e) {
     throw ExpenseDataSourceException('Failed to get category expense summary: $e');
   }
 }

 /// Get monthly expense summary
 Future<List<MonthlyExpenseSummary>> getMonthlyExpenseSummary({
   int? year,
   int? limitMonths,
 }) async {
   try {
     final whereConditions = <String>['c.is_active = 1'];
     final whereArgs = <dynamic>[];
     
     if (year != null) {
       final startOfYear = DateTime(year, 1, 1).millisecondsSinceEpoch;
       final endOfYear = DateTime(year + 1, 1, 1).subtract(Duration(milliseconds: 1)).millisecondsSinceEpoch;
       whereConditions.add('e.date >= ? AND e.date <= ?');
       whereArgs.addAll([startOfYear, endOfYear]);
     }
     
     String sql = '''
       SELECT 
         strftime('%Y-%m', datetime(e.date/1000, 'unixepoch')) as month,
         COALESCE(SUM(e.amount), 0) as total_amount,
         COUNT(e.id) as expense_count,
         COALESCE(AVG(e.amount), 0) as average_amount
       FROM ${DatabaseTables.expenses} e
       INNER JOIN ${DatabaseTables.categories} c ON e.category_id = c.id
       WHERE ${whereConditions.join(' AND ')}
       GROUP BY month
       ORDER BY month DESC
       ${limitMonths != null ? 'LIMIT $limitMonths' : ''}
     ''';
     
     final monthlyResults = await _databaseHelper.rawQuery(sql, whereArgs);
     
     final summaries = <MonthlyExpenseSummary>[];
     
     for (final monthRow in monthlyResults) {
       final month = monthRow['month'] as String;
       
       // Get category breakdown for this month
       final categoryBreakdown = await _getCategoryBreakdownForMonth(month);
       
       summaries.add(MonthlyExpenseSummary(
         month: month,
         totalAmount: (monthRow['total_amount'] as num).toDouble(),
         expenseCount: monthRow['expense_count'] as int,
         averageAmount: (monthRow['average_amount'] as num).toDouble(),
         categoryBreakdown: categoryBreakdown,
       ));
     }
     
     return summaries;
   } catch (e) {
     throw ExpenseDataSourceException('Failed to get monthly expense summary: $e');
   }
 }

 /// Get category breakdown for a specific month
 Future<List<CategoryExpenseSummary>> _getCategoryBreakdownForMonth(String month) async {
   String sql = '''
     WITH month_total AS (
       SELECT COALESCE(SUM(e.amount), 0) as total
       FROM ${DatabaseTables.expenses} e
       INNER JOIN ${DatabaseTables.categories} c ON e.category_id = c.id
       WHERE strftime('%Y-%m', datetime(e.date/1000, 'unixepoch')) = ? AND c.is_active = 1
     )
     SELECT 
       c.id as category_id,
       c.name as category_name,
       c.icon_code as category_icon,
       c.color_value as category_color,
       COALESCE(SUM(e.amount), 0) as total_amount,
       COUNT(e.id) as expense_count,
       COALESCE(AVG(e.amount), 0) as average_amount,
       CASE 
         WHEN month_total.total > 0 THEN (COALESCE(SUM(e.amount), 0) * 100.0 / month_total.total)
         ELSE 0
       END as percentage
     FROM ${DatabaseTables.categories} c
     LEFT JOIN ${DatabaseTables.expenses} e ON c.id = e.category_id 
       AND strftime('%Y-%m', datetime(e.date/1000, 'unixepoch')) = ?
     CROSS JOIN month_total
     WHERE c.is_active = 1
     GROUP BY c.id, c.name, c.icon_code, c.color_value, month_total.total
     HAVING COUNT(e.id) > 0
     ORDER BY total_amount DESC
   ''';
   
   final result = await _databaseHelper.rawQuery(sql, [month, month]);
   
   return result.map((row) => CategoryExpenseSummary(
     categoryId: row['category_id'] as int,
     categoryName: row['category_name'] as String,
     categoryIcon: row['category_icon'] as int,
     categoryColor: row['category_color'] as int,
     totalAmount: (row['total_amount'] as num).toDouble(),
     expenseCount: row['expense_count'] as int,
     averageAmount: (row['average_amount'] as num).toDouble(),
     percentage: (row['percentage'] as num).toDouble(),
   )).toList();
 }

 /// Check if category has expenses
 Future<bool> categoryHasExpenses(int categoryId) async {
   try {
     final result = await _databaseHelper.query(
       DatabaseTables.expenses,
       columns: ['id'],
       where: 'category_id = ?',
       whereArgs: [categoryId],
       limit: 1,
     );
     
     return result.isNotEmpty;
   } catch (e) {
     throw ExpenseDataSourceException('Failed to check if category has expenses: $e');
   }
 }

 /// Bulk insert expenses
 Future<List<Expense>> bulkInsertExpenses(List<Expense> expenses) async {
   try {
     return await _databaseHelper.transaction<List<Expense>>((txn) async {
       final insertedExpenses = <Expense>[];
       
       for (final expense in expenses) {
         final id = await txn.insert(
           DatabaseTables.expenses,
           expense.toDatabase(),
         );
         insertedExpenses.add(expense.copyWith(id: id));
       }
       
       return insertedExpenses;
     });
   } catch (e) {
     throw ExpenseDataSourceException('Failed to bulk insert expenses: $e');
   }
 }

 /// Bulk update expenses
 Future<void> bulkUpdateExpenses(List<Expense> expenses) async {
   try {
     await _databaseHelper.transaction<void>((txn) async {
       for (final expense in expenses) {
         if (expense.id == null) continue;
         
         final updatedExpense = expense.copyWith(updatedAt: DateTime.now());
         
         await txn.update(
           DatabaseTables.expenses,
           updatedExpense.toDatabase(),
           where: 'id = ?',
           whereArgs: [expense.id!],
         );
       }
     });
   } catch (e) {
     throw ExpenseDataSourceException('Failed to bulk update expenses: $e');
   }
 }

 /// Bulk delete expenses
 Future<void> bulkDeleteExpenses(List<int> ids) async {
   try {
     if (ids.isEmpty) return;
     
     final placeholders = List.filled(ids.length, '?').join(',');
     
     await _databaseHelper.delete(
       DatabaseTables.expenses,
       'id IN ($placeholders)',
       ids,
     );
   } catch (e) {
     throw ExpenseDataSourceException('Failed to bulk delete expenses: $e');
   }
 }

 /// Helper method to build ORDER BY clause for regular queries
 String _buildOrderByClause(ExpenseSortOption sortOption, bool ascending) {
   final direction = ascending ? 'ASC' : 'DESC';
   
   switch (sortOption) {
     case ExpenseSortOption.dateNewest:
       return 'date DESC';
     case ExpenseSortOption.dateOldest:
       return 'date ASC';
     case ExpenseSortOption.amountHighest:
       return 'amount DESC';
     case ExpenseSortOption.amountLowest:
       return 'amount ASC';
     case ExpenseSortOption.description:
       return 'description $direction';
     case ExpenseSortOption.category:
       return 'category_id $direction';
   }
 }

 /// Helper method to build ORDER BY clause for joined queries
 String _buildOrderByClauseForJoin(ExpenseSortOption sortOption, bool ascending) {
   final direction = ascending ? 'ASC' : 'DESC';
   
   switch (sortOption) {
     case ExpenseSortOption.dateNewest:
       return 'e.date DESC';
     case ExpenseSortOption.dateOldest:
       return 'e.date ASC';
     case ExpenseSortOption.amountHighest:
       return 'e.amount DESC';
     case ExpenseSortOption.amountLowest:
       return 'e.amount ASC';
     case ExpenseSortOption.description:
       return 'e.description $direction';
     case ExpenseSortOption.category:
       return 'c.name $direction';
   }
 }
}

/// Custom exception for expense data source operations
class ExpenseDataSourceException implements Exception {
 final String message;
 
 const ExpenseDataSourceException(this.message);
 
 @override
 String toString() => 'ExpenseDataSourceException: $message';
}
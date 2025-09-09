import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../data_sources/expense_local_data_source.dart';
import '../models/expense.dart';

/// Implementation of ExpenseRepository using local data source
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource _localDataSource;

  const ExpenseRepositoryImpl(this._localDataSource);

  @override
  Future<List<ExpenseEntity>> getAllExpenses() async {
    try {
      final expenses = await _localDataSource.getAllExpenses();
      return expenses.map((expense) => expense.toEntity()).toList();
    } catch (e) {
      throw ExpenseRepositoryException('Failed to get all expenses', e);
    }
  }

  @override
  Future<ExpenseEntity?> getExpenseById(int id) async {
    try {
      final expense = await _localDataSource.getExpenseById(id);
      return expense?.toEntity();
    } catch (e) {
      throw ExpenseRepositoryException('Failed to get expense by ID', e);
    }
  }

  @override
  Future<ExpenseEntity> createExpense(ExpenseEntity expense) async {
    try {
      // Validate expense data
      final validationErrors = expense.validate();
      if (validationErrors.isNotEmpty) {
        throw ExpenseRepositoryException(
          'Invalid expense data: ${validationErrors.join(', ')}', 
          null,
        );
      }

      // Convert to data model and insert
      final expenseModel = Expense.fromEntity(expense).copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final insertedExpense = await _localDataSource.insertExpense(expenseModel);
      return insertedExpense.toEntity();
    } catch (e) {
      if (e is ExpenseRepositoryException) rethrow;
      throw ExpenseRepositoryException('Failed to create expense', e);
    }
  }

  @override
  Future<ExpenseEntity> updateExpense(ExpenseEntity expense) async {
    try {
      if (expense.id == null) {
        throw ExpenseRepositoryException('Cannot update expense without ID', null);
      }

      // Validate expense data
      final validationErrors = expense.validate();
      if (validationErrors.isNotEmpty) {
        throw ExpenseRepositoryException(
          'Invalid expense data: ${validationErrors.join(', ')}', 
          null,
        );
      }

      // Check if expense exists
      final existingExpense = await _localDataSource.getExpenseById(expense.id!);
      if (existingExpense == null) {
        throw ExpenseRepositoryException('Expense not found for update', null);
      }

      // Convert to data model and update
      final expenseModel = Expense.fromEntity(expense);
      final updatedExpense = await _localDataSource.updateExpense(expenseModel);
      return updatedExpense.toEntity();
    } catch (e) {
      if (e is ExpenseRepositoryException) rethrow;
      throw ExpenseRepositoryException('Failed to update expense', e);
    }
  }

  @override
  Future<void> deleteExpense(int id) async {
    try {
      // Check if expense exists
      final expense = await _localDataSource.getExpenseById(id);
      if (expense == null) {
        throw ExpenseRepositoryException('Expense not found for deletion', null);
      }

      await _localDataSource.deleteExpense(id);
    } catch (e) {
      if (e is ExpenseRepositoryException) rethrow;
      throw ExpenseRepositoryException('Failed to delete expense', e);
    }
  }

  @override
  Future<List<ExpenseEntity>> getExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      if (startDate.isAfter(endDate)) {
        throw ExpenseRepositoryException('Start date cannot be after end date', null);
      }

      final expenses = await _localDataSource.getExpensesByDateRange(startDate, endDate);
      return expenses.map((expense) => expense.toEntity()).toList();
    } catch (e) {
      if (e is ExpenseRepositoryException) rethrow;
      throw ExpenseRepositoryException('Failed to get expenses by date range', e);
    }
  }

  @override
  Future<List<ExpenseEntity>> getExpensesByCategory(int categoryId) async {
    try {
      final expenses = await _localDataSource.getExpensesByCategory(categoryId);
      return expenses.map((expense) => expense.toEntity()).toList();
    } catch (e) {
      throw ExpenseRepositoryException('Failed to get expenses by category', e);
    }
  }

  @override
  Future<List<ExpenseEntity>> getExpensesByCategories(List<int> categoryIds) async {
    try {
      if (categoryIds.isEmpty) return [];
      
      final expenses = await _localDataSource.getExpensesByCategories(categoryIds);
      return expenses.map((expense) => expense.toEntity()).toList();
    } catch (e) {
      throw ExpenseRepositoryException('Failed to get expenses by categories', e);
    }
  }

  @override
  Future<List<ExpenseEntity>> searchExpenses(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllExpenses();
      }
      
      final expenses = await _localDataSource.searchExpenses(query);
      return expenses.map((expense) => expense.toEntity()).toList();
    } catch (e) {
      throw ExpenseRepositoryException('Failed to search expenses', e);
    }
  }

  @override
  Future<List<ExpenseEntity>> getFilteredExpenses(ExpenseFilter filter) async {
    try {
      final expenses = await _localDataSource.getFilteredExpenses(filter);
      return expenses.map((expense) => expense.toEntity()).toList();
    } catch (e) {
      throw ExpenseRepositoryException('Failed to get filtered expenses', e);
    }
  }

  @override
  Future<List<ExpenseEntity>> getExpensesPaginated({
    int offset = 0,
    int limit = 20,
    ExpenseFilter? filter,
  }) async {
    try {
      if (limit <= 0) {
        throw ExpenseRepositoryException('Limit must be greater than 0', null);
      }
      if (offset < 0) {
        throw ExpenseRepositoryException('Offset must be non-negative', null);
      }

      final expenses = await _localDataSource.getExpensesPaginated(
        offset: offset,
        limit: limit,
        filter: filter,
      );
      return expenses.map((expense) => expense.toEntity()).toList();
    } catch (e) {
      if (e is ExpenseRepositoryException) rethrow;
      throw ExpenseRepositoryException('Failed to get paginated expenses', e);
    }
  }

  @override
  Future<List<ExpenseWithCategory>> getExpensesWithCategories({
    ExpenseFilter? filter,
    int? limit,
    int? offset,
  }) async {
    try {
      return await _localDataSource.getExpensesWithCategories(
        filter: filter,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      throw ExpenseRepositoryException('Failed to get expenses with categories', e);
    }
  }

  @override
  Future<ExpenseWithCategory?> getExpenseWithCategoryById(int id) async {
    try {
      return await _localDataSource.getExpenseWithCategoryById(id);
    } catch (e) {
      throw ExpenseRepositoryException('Failed to get expense with category by ID', e);
    }
  }

  @override
  Future<List<ExpenseEntity>> getTodayExpenses() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
      
      return await getExpensesByDateRange(startOfDay, endOfDay);
    } catch (e) {
      throw ExpenseRepositoryException('Failed to get today expenses', e);
    }
  }

  @override
  Future<List<ExpenseEntity>> getThisWeekExpenses() async {
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      final endOfWeek = startOfWeekDay.add(const Duration(days: 7)).subtract(const Duration(milliseconds: 1));
      
      return await getExpensesByDateRange(startOfWeekDay, endOfWeek);
    } catch (e) {
      throw ExpenseRepositoryException('Failed to get this week expenses', e);
    }
  }

  @override
  Future<List<ExpenseEntity>> getThisMonthExpenses() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(milliseconds: 1));
      
      return await getExpensesByDateRange(startOfMonth, endOfMonth);
    } catch (e) {
      throw ExpenseRepositoryException('Failed to get this month expenses', e);
    }
  }

  @override
  Future<List<ExpenseEntity>> getThisYearExpenses() async {
    try {
      final now = DateTime.now();
      final startOfYear = DateTime(now.year, 1, 1);
      final endOfYear = DateTime(now.year + 1, 1, 1).subtract(const Duration(milliseconds: 1));
      
      return await getExpensesByDateRange(startOfYear, endOfYear);
    } catch (e) {
      throw ExpenseRepositoryException('Failed to get this year expenses', e);
    }
  }

  @override
  Future<List<ExpenseEntity>> getExpensesByMonth(int year, int month) async {
    try {
      if (month < 1 || month > 12) {
        throw ExpenseRepositoryException('Month must be between 1 and 12', null);
      }

      final startOfMonth = DateTime(year, month, 1);
      final endOfMonth = DateTime(year, month + 1, 1).subtract(const Duration(milliseconds: 1));
      
      return await getExpensesByDateRange(startOfMonth, endOfMonth);
    } catch (e) {
      if (e is ExpenseRepositoryException) rethrow;
      throw ExpenseRepositoryException('Failed to get expenses by month', e);
    }
  }

  @override
  Future<List<ExpenseEntity>> getExpensesByYear(int year) async {
    try {
      final startOfYear = DateTime(year, 1, 1);
      final endOfYear = DateTime(year + 1, 1, 1).subtract(const Duration(milliseconds: 1));
      
      return await getExpensesByDateRange(startOfYear, endOfYear);
    } catch (e) {
      throw ExpenseRepositoryException('Failed to get expenses by year', e);
    }
  }

  @override
  Future<ExpenseStats> getExpenseStats({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
  }) async {
    try {
      if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
        throw ExpenseRepositoryException('Start date cannot be after end date', null);
      }

      return await _localDataSource.getExpenseStats(
        startDate: startDate,
        endDate: endDate,
        categoryIds: categoryIds,
      );
    } catch (e) {
      if (e is ExpenseRepositoryException) rethrow;
      throw ExpenseRepositoryException('Failed to get expense stats', e);
    }
  }

  @override
  Future<List<CategoryExpenseSummary>> getCategoryExpenseSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (startDate != null && endDate != null && startDate.isAfter(endDate)) {
        throw ExpenseRepositoryException('Start date cannot be after end date', null);
      }

      return await _localDataSource.getCategoryExpenseSummary(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      if (e is ExpenseRepositoryException) rethrow;
      throw ExpenseRepositoryException('Failed to get category expense summary', e);
    }
  }

  @override
  Future<List<MonthlyExpenseSummary>> getMonthlyExpenseSummary({
    int? year,
    int? limitMonths,
  }) async {
    try {
      if (limitMonths != null && limitMonths <= 0) {
        throw ExpenseRepositoryException('Limit months must be greater than 0', null);
      }

      return await _localDataSource.getMonthlyExpenseSummary(
        year: year,
        limitMonths: limitMonths,
      );
    } catch (e) {
      if (e is ExpenseRepositoryException) rethrow;
      throw ExpenseRepositoryException('Failed to get monthly expense summary', e);
    }
  }

  @override
  Future<double> getTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
  }) async {
    try {
      final stats = await getExpenseStats(
        startDate: startDate,
        endDate: endDate,
        categoryIds: categoryIds,
      );
      return stats.totalAmount;
    } catch (e) {
      throw ExpenseRepositoryException('Failed to get total expenses', e);
    }
  }

  @override
  Future<double> getAverageExpenseAmount({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
  }) async {
    try {
      final stats = await getExpenseStats(
        startDate: startDate,
        endDate: endDate,
        categoryIds: categoryIds,
      );
      return stats.averageAmount;
    } catch (e) {
      throw ExpenseRepositoryException('Failed to get average expense amount', e);
    }
  }

  @override
  Future<int> getExpenseCount({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
  }) async {
    try {
      final stats = await getExpenseStats(
        startDate: startDate,
        endDate: endDate,
        categoryIds: categoryIds,
      );
      return stats.expenseCount;
    } catch (e) {
      throw ExpenseRepositoryException('Failed to get expense count', e);
    }
  }

  @override
  Future<ExpenseEntity?> getHighestExpense({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
  }) async {
    try {
      final filter = ExpenseFilter(
        startDate: startDate,
        endDate: endDate,
        categoryIds: categoryIds,
        sortOption: ExpenseSortOption.amountHighest,
      );
      
      final expenses = await _localDataSource.getFilteredExpenses(filter);
      if (expenses.isEmpty) return null;
      
      return expenses.first.toEntity();
    } catch (e) {
      throw ExpenseRepositoryException('Failed to get highest expense', e);
    }
  }

  @override
  Future<ExpenseEntity?> getLowestExpense({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
  }) async {
    try {
      final filter = ExpenseFilter(
        startDate: startDate,
        endDate: endDate,
        categoryIds: categoryIds,
        sortOption: ExpenseSortOption.amountLowest,
      );
      
      final expenses = await _localDataSource.getFilteredExpenses(filter);
      if (expenses.isEmpty) return null;
      
      return expenses.first.toEntity();
    } catch (e) {
      throw ExpenseRepositoryException('Failed to get lowest expense', e);
    }
  }

  @override
  Future<List<ExpenseEntity>> getRecentExpensesByCategory(int categoryId, {int limit = 10}) async {
    try {
      if (limit <= 0) {
        throw ExpenseRepositoryException('Limit must be greater than 0', null);
      }

      final filter = ExpenseFilter(
        categoryIds: [categoryId],
        sortOption: ExpenseSortOption.dateNewest,
      );
      
      final expenses = await _localDataSource.getExpensesPaginated(
        limit: limit,
        filter: filter,
      );
      return expenses.map((expense) => expense.toEntity()).toList();
    } catch (e) {
      if (e is ExpenseRepositoryException) rethrow;
      throw ExpenseRepositoryException('Failed to get recent expenses by category', e);
    }
  }

  @override
  Future<double> getTotalExpensesByCategory(int categoryId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      return await getTotalExpenses(
        startDate: startDate,
        endDate: endDate,
        categoryIds: [categoryId],
      );
    } catch (e) {
      throw ExpenseRepositoryException('Failed to get total expenses by category', e);
    }
  }

  @override
  Future<bool> categoryHasExpenses(int categoryId) async {
    try {
      return await _localDataSource.categoryHasExpenses(categoryId);
    } catch (e) {
      throw ExpenseRepositoryException('Failed to check if category has expenses', e);
    }
  }

  @override
  Future<List<int>> getUsedCategoryIds() async {
    try {
      final expenses = await _localDataSource.getAllExpenses();
      final categoryIds = expenses.map((expense) => expense.categoryId).toSet().toList();
      return categoryIds;
    } catch (e) {
      throw ExpenseRepositoryException('Failed to get used category IDs', e);
    }
  }

  @override
  Future<List<ExpenseEntity>> bulkCreateExpenses(List<ExpenseEntity> expenses) async {
    try {
      // Validate all expenses
      for (final expense in expenses) {
        final validationErrors = expense.validate();
        if (validationErrors.isNotEmpty) {
          throw ExpenseRepositoryException(
            'Invalid expense data: ${validationErrors.join(', ')}', 
            null,
          );
        }
      }

      // Convert to data models with timestamps
      final expenseModels = expenses
          .map((entity) => Expense.fromEntity(entity).copyWith(
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ))
          .toList();

      final insertedExpenses = await _localDataSource.bulkInsertExpenses(expenseModels);
      return insertedExpenses.map((expense) => expense.toEntity()).toList();
    } catch (e) {
      if (e is ExpenseRepositoryException) rethrow;
      throw ExpenseRepositoryException('Failed to bulk create expenses', e);
    }
  }

  @override
  Future<void> bulkUpdateExpenses(List<ExpenseEntity> expenses) async {
    try {
      // Validate all expenses have IDs
      for (final expense in expenses) {
        if (expense.id == null) {
          throw ExpenseRepositoryException('Cannot update expense without ID', null);
        }
        
        final validationErrors = expense.validate();
        if (validationErrors.isNotEmpty) {
          throw ExpenseRepositoryException(
            'Invalid expense data: ${validationErrors.join(', ')}', 
            null,
          );
        }
      }

      // Convert to data models
      final expenseModels = expenses
          .map((entity) => Expense.fromEntity(entity))
          .toList();

      await _localDataSource.bulkUpdateExpenses(expenseModels);
    } catch (e) {
      if (e is ExpenseRepositoryException) rethrow;
      throw ExpenseRepositoryException('Failed to bulk update expenses', e);
    }
  }

  @override
  Future<void> bulkDeleteExpenses(List<int> ids) async {
    try {
      if (ids.isEmpty) return;

      await _localDataSource.bulkDeleteExpenses(ids);
    } catch (e) {
      throw ExpenseRepositoryException('Failed to bulk delete expenses', e);
    }
  }

// @override
//  Future<void> bulkDeleteExpenses(List<int> expenseIds) async {
//    for (final id in expenseIds) {
//      await deleteExpense(id);
//    }
//  }


  @override
  Future<void> deleteExpensesByCategory(int categoryId) async {
    try {
      final expenses = await getExpensesByCategory(categoryId);
      if (expenses.isNotEmpty) {
        final ids = expenses.map((expense) => expense.id!).toList();
        await bulkDeleteExpenses(ids);
      }
    } catch (e) {
      throw ExpenseRepositoryException('Failed to delete expenses by category', e);
    }
  }

  @override
  Future<void> deleteExpensesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final expenses = await getExpensesByDateRange(startDate, endDate);
      if (expenses.isNotEmpty) {
        final ids = expenses.map((expense) => expense.id!).toList();
        await bulkDeleteExpenses(ids);
      }
    } catch (e) {
      throw ExpenseRepositoryException('Failed to delete expenses by date range', e);
    }
  }

  @override
  Future<void> deleteAllExpenses() async {
    try {
      final expenses = await getAllExpenses();
      if (expenses.isNotEmpty) {
        final ids = expenses.map((expense) => expense.id!).toList();
        await bulkDeleteExpenses(ids);
      }
    } catch (e) {
      throw ExpenseRepositoryException('Failed to delete all expenses', e);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> exportExpensesToJson({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final expenses = startDate != null && endDate != null
          ? await getExpensesByDateRange(startDate, endDate)
          : await getAllExpenses();

      return expenses
          .map((expense) => Expense.fromEntity(expense).toJson())
          .toList();
    } catch (e) {
      throw ExpenseRepositoryException('Failed to export expenses to JSON', e);
    }
  }

  @override
  Future<void> importExpensesFromJson(List<Map<String, dynamic>> jsonData) async {
    try {
      final expenses = jsonData
          .map((json) => Expense.fromJson(json).toEntity())
          .toList();

      await bulkCreateExpenses(expenses);
    } catch (e) {
      throw ExpenseRepositoryException('Failed to import expenses from JSON', e);
    }
  }

  @override
  Future<List<ExpenseEntity>> getRecentExpenses({int limit = 10}) async {
    try {
      if (limit <= 0) {
        throw ExpenseRepositoryException('Limit must be greater than 0', null);
      }

      final filter = ExpenseFilter(sortOption: ExpenseSortOption.dateNewest);
      
      final expenses = await _localDataSource.getExpensesPaginated(
        limit: limit,
        filter: filter,
      );
      return expenses.map((expense) => expense.toEntity()).toList();
    } catch (e) {
      if (e is ExpenseRepositoryException) rethrow;
      throw ExpenseRepositoryException('Failed to get recent expenses', e);
    }
  }

// @override
//  Future<List<ExpenseEntity>> getRecentExpenses({int limit = 10}) async {
//    final expenses = await getAllExpenses();
//    expenses.sort((a, b) => b.date.compareTo(a.date));
//    return expenses.take(limit).toList();
//  }

  @override
  Future<List<ExpenseEntity>> getSimilarExpenses(ExpenseEntity expense, {int limit = 5}) async {
    try {
      if (limit <= 0) {
        throw ExpenseRepositoryException('Limit must be greater than 0', null);
      }

      // Find similar expenses by category and similar amount
      final minAmount = expense.amount * 0.8; // 20% less
      final maxAmount = expense.amount * 1.2; // 20% more

      final filter = ExpenseFilter(
        categoryIds: [expense.categoryId],
        minAmount: minAmount,
        maxAmount: maxAmount,
        sortOption: ExpenseSortOption.dateNewest,
      );

      final expenses = await _localDataSource.getExpensesPaginated(
        limit: limit + 1, // Get one extra in case the expense itself is included
        filter: filter,
      );

      // Filter out the expense itself if it exists
      final similarExpenses = expenses
          .where((e) => e.id != expense.id)
          .take(limit)
          .map((expense) => expense.toEntity())
          .toList();

      return similarExpenses;
    } catch (e) {
      if (e is ExpenseRepositoryException) rethrow;
      throw ExpenseRepositoryException('Failed to get similar expenses', e);
    }
  }

  @override
  Future<List<ExpenseEntity>> getExpenses({
    int offset = 0,
    int limit = 20,
    String? searchQuery,
    int? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    List<String>? tags,
    String? sortBy,
    bool ascending = false,
  }) async {
    // For now, use getAllExpenses and filter manually
    final allExpenses = await getAllExpenses();
    
    // Apply filters
    var filteredExpenses = allExpenses.where((expense) {
      // Search filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        if (!expense.description.toLowerCase().contains(searchQuery.toLowerCase())) {
          return false;
        }
      }
      
      // Category filter
      if (categoryId != null && expense.categoryId != categoryId) {
        return false;
      }
      
      // Date filters
      if (startDate != null && expense.date.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && expense.date.isAfter(endDate)) {
       return false;
     }
     
     // Amount filters
     if (minAmount != null && expense.amount < minAmount) {
       return false;
     }
     if (maxAmount != null && expense.amount > maxAmount) {
       return false;
     }
     
     return true;
   }).toList();
   
   // Sort expenses
   filteredExpenses.sort((a, b) {
     int result;
     switch (sortBy) {
       case 'amount':
         result = a.amount.compareTo(b.amount);
         break;
       case 'category':
         result = a.categoryId.compareTo(b.categoryId);
         break;
       case 'description':
         result = a.description.compareTo(b.description);
         break;
       case 'date':
       default:
         result = a.date.compareTo(b.date);
         break;
     }
     return ascending ? result : -result;
   });
   
   // Apply pagination
   final startIndex = offset.clamp(0, filteredExpenses.length);
   final endIndex = (offset + limit).clamp(0, filteredExpenses.length);
   
   return filteredExpenses.sublist(startIndex, endIndex);
 }

 @override
 Future<void> bulkUpdateCategory(List<int> expenseIds, int newCategoryId) async {
   for (final id in expenseIds) {
     final expense = await getExpenseById(id);
     if (expense != null) {
       final updatedExpense = ExpenseEntity(
         id: expense.id,
         amount: expense.amount,
         description: expense.description,
         categoryId: newCategoryId,
         date: expense.date,
         createdAt: expense.createdAt,
         updatedAt: DateTime.now(),
       );
       await updateExpense(updatedExpense);
     }
   }
 }
}

/// Custom exception for expense repository operations
class ExpenseRepositoryException implements Exception {
  final String message;
  final dynamic originalError;
  
  const ExpenseRepositoryException(this.message, this.originalError);
  
  @override
  String toString() {
    if (originalError != null) {
      return 'ExpenseRepositoryException: $message\nCaused by: $originalError';
    }
    return 'ExpenseRepositoryException: $message';
  }
}
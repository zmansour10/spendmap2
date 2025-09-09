import '../entities/expense_entity.dart';
import '../../data/models/expense.dart';

/// Abstract repository interface for expense operations
abstract class ExpenseRepository {
  // Basic CRUD operations
  Future<List<ExpenseEntity>> getAllExpenses();
  Future<ExpenseEntity?> getExpenseById(int id);
  Future<ExpenseEntity> createExpense(ExpenseEntity expense);
  Future<ExpenseEntity> updateExpense(ExpenseEntity expense);
  Future<void> deleteExpense(int id);
  
  // Advanced querying
  Future<List<ExpenseEntity>> getExpensesByDateRange(DateTime startDate, DateTime endDate);
  Future<List<ExpenseEntity>> getExpensesByCategory(int categoryId);
  Future<List<ExpenseEntity>> getExpensesByCategories(List<int> categoryIds);
  Future<List<ExpenseEntity>> searchExpenses(String query);
  Future<List<ExpenseEntity>> getFilteredExpenses(ExpenseFilter filter);
  
  // Paginated queries
  Future<List<ExpenseEntity>> getExpensesPaginated({
    int offset = 0,
    int limit = 20,
    ExpenseFilter? filter,
  });
  
  // Joined data queries
  Future<List<ExpenseWithCategory>> getExpensesWithCategories({
    ExpenseFilter? filter,
    int? limit,
    int? offset,
  });
  
  Future<ExpenseWithCategory?> getExpenseWithCategoryById(int id);
  
  // Date-based queries
  Future<List<ExpenseEntity>> getTodayExpenses();
  Future<List<ExpenseEntity>> getThisWeekExpenses();
  Future<List<ExpenseEntity>> getThisMonthExpenses();
  Future<List<ExpenseEntity>> getThisYearExpenses();
  Future<List<ExpenseEntity>> getExpensesByMonth(int year, int month);
  Future<List<ExpenseEntity>> getExpensesByYear(int year);
  
  // Statistics and analytics
  Future<ExpenseStats> getExpenseStats({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
  });
  
  Future<List<CategoryExpenseSummary>> getCategoryExpenseSummary({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<List<MonthlyExpenseSummary>> getMonthlyExpenseSummary({
    int? year,
    int? limitMonths,
  });
  
  // Aggregation queries
  Future<double> getTotalExpenses({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
  });
  
  Future<double> getAverageExpenseAmount({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
  });
  
  Future<int> getExpenseCount({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
  });
  
  Future<ExpenseEntity?> getHighestExpense({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
  });
  
  Future<ExpenseEntity?> getLowestExpense({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
  });
  
  // Category-related queries
  Future<List<ExpenseEntity>> getRecentExpensesByCategory(int categoryId, {int limit = 10});
  Future<double> getTotalExpensesByCategory(int categoryId, {DateTime? startDate, DateTime? endDate});
  Future<bool> categoryHasExpenses(int categoryId);
  Future<List<int>> getUsedCategoryIds();
  
  // Bulk operations
  Future<List<ExpenseEntity>> bulkCreateExpenses(List<ExpenseEntity> expenses);
  Future<void> bulkUpdateExpenses(List<ExpenseEntity> expenses);
  Future<void> bulkDeleteExpenses(List<int> ids);
  
  // Data management
  Future<void> deleteExpensesByCategory(int categoryId);
  Future<void> deleteExpensesByDateRange(DateTime startDate, DateTime endDate);
  Future<void> deleteAllExpenses();
  
  // Export/Import support
  Future<List<Map<String, dynamic>>> exportExpensesToJson({
    DateTime? startDate,
    DateTime? endDate,
  });
  
  Future<void> importExpensesFromJson(List<Map<String, dynamic>> jsonData);
  
  // Recent and favorites
  Future<List<ExpenseEntity>> getRecentExpenses({int limit = 10});
  Future<List<ExpenseEntity>> getSimilarExpenses(ExpenseEntity expense, {int limit = 5});

   /// Get expenses with pagination and filtering
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
  });

  /// Bulk update category
  Future<void> bulkUpdateCategory(List<int> expenseIds, int newCategoryId);
}
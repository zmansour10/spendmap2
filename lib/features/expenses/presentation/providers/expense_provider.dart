import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/expense_entity.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../data/data_sources/expense_local_data_source.dart';
import '../../data/models/expense.dart';
import '../../../shared/providers/database_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';

part 'expense_provider.g.dart';

// Expense Repository Provider
@riverpod
ExpenseRepository expenseRepository(ExpenseRepositoryRef ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  final dataSource = ExpenseLocalDataSource(databaseHelper);
  return ExpenseRepositoryImpl(dataSource);
}

// All Expenses Provider
@riverpod
class Expenses extends _$Expenses {
  @override
  Future<List<ExpenseEntity>> build() async {
    final repository = ref.watch(expenseRepositoryProvider);
    return await repository.getAllExpenses();
  }

  /// Refresh expenses
  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// Add a new expense
  Future<ExpenseEntity> addExpense(ExpenseEntity expense) async {
    final repository = ref.watch(expenseRepositoryProvider);
    
    try {
      final newExpense = await repository.createExpense(expense);
      
      // Refresh the list to include the new expense
      ref.invalidateSelf();
      
      // Also invalidate related providers
      ref.invalidate(recentExpensesProvider);
      ref.invalidate(expenseStatisticsProvider);
      
      return newExpense;
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing expense
  Future<ExpenseEntity> updateExpense(ExpenseEntity expense) async {
    final repository = ref.watch(expenseRepositoryProvider);
    
    try {
      final updatedExpense = await repository.updateExpense(expense);
      
      // Update the local state optimistically
      final currentState = state.valueOrNull ?? [];
      final updatedList = currentState.map((exp) {
        return exp.id == expense.id ? updatedExpense : exp;
      }).toList();
      
      state = AsyncValue.data(updatedList);
      
      // Invalidate related providers
      ref.invalidate(expenseStatisticsProvider);
      
      return updatedExpense;
    } catch (e) {
      // Refresh on error to get correct state
      ref.invalidateSelf();
      rethrow;
    }
  }

  /// Delete an expense
  Future<void> deleteExpense(int expenseId) async {
    final repository = ref.watch(expenseRepositoryProvider);
    
    try {
      await repository.deleteExpense(expenseId);
      
      // Remove from local state optimistically
      final currentState = state.valueOrNull ?? [];
      final updatedList = currentState.where((exp) => exp.id != expenseId).toList();
      state = AsyncValue.data(updatedList);
      
      // Invalidate related providers
      ref.invalidate(expenseStatisticsProvider);
    } catch (e) {
      // Refresh on error
      ref.invalidateSelf();
      rethrow;
    }
  }

  /// Bulk delete expenses
  Future<void> bulkDeleteExpenses(List<int> expenseIds) async {
    final repository = ref.watch(expenseRepositoryProvider);
    
    try {
      await repository.bulkDeleteExpenses(expenseIds);
      
      // Remove from local state
      final currentState = state.valueOrNull ?? [];
      final updatedList = currentState
          .where((exp) => !expenseIds.contains(exp.id))
          .toList();
      state = AsyncValue.data(updatedList);
      
      // Invalidate related providers
      ref.invalidate(expenseStatisticsProvider);
    } catch (e) {
      ref.invalidateSelf();
      rethrow;
    }
  }
}

// Expenses with Categories Provider (joined data)
@riverpod
class ExpensesWithCategories extends _$ExpensesWithCategories {
  @override
  Future<List<ExpenseWithCategory>> build({ExpenseFilter? filter}) async {
    final repository = ref.watch(expenseRepositoryProvider);
    return await repository.getExpensesWithCategories(filter: filter);
  }

  /// Refresh with current filter
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

// Recent Expenses Provider (last 10)
@riverpod
Future<List<ExpenseEntity>> recentExpenses(RecentExpensesRef ref, {int limit = 10}) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getRecentExpenses(limit: limit);
}

// Today's Expenses Provider
@riverpod
Future<List<ExpenseEntity>> todayExpenses(TodayExpensesRef ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getTodayExpenses();
}

// This Week's Expenses Provider
@riverpod
Future<List<ExpenseEntity>> thisWeekExpenses(ThisWeekExpensesRef ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getThisWeekExpenses();
}

// This Month's Expenses Provider
@riverpod
Future<List<ExpenseEntity>> thisMonthExpenses(ThisMonthExpensesRef ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getThisMonthExpenses();
}

// Expense by ID Provider (Family)
@riverpod
Future<ExpenseEntity?> expenseById(ExpenseByIdRef ref, int expenseId) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getExpenseById(expenseId);
}

// Expenses by Category Provider (Family)
@riverpod
Future<List<ExpenseEntity>> expensesByCategory(ExpensesByCategoryRef ref, int categoryId) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getExpensesByCategory(categoryId);
}

// Expenses by Date Range Provider (Family)
@riverpod
Future<List<ExpenseEntity>> expensesByDateRange(
  ExpensesByDateRangeRef ref,
  DateTime startDate,
  DateTime endDate,
) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getExpensesByDateRange(startDate, endDate);
}

// Expense Statistics Provider
@riverpod
class ExpenseStatistics extends _$ExpenseStatistics {
  @override
  Future<ExpenseStats> build({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
  }) async {
    final repository = ref.watch(expenseRepositoryProvider);
    return await repository.getExpenseStats(
      startDate: startDate,
      endDate: endDate,
      categoryIds: categoryIds,
    );
  }

  /// Refresh statistics
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

// Category Expense Summary Provider
@riverpod
Future<List<CategoryExpenseSummary>> categoryExpenseSummary(
  CategoryExpenseSummaryRef ref, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getCategoryExpenseSummary(
    startDate: startDate,
    endDate: endDate,
  );
}

// Monthly Expense Summary Provider
@riverpod
Future<List<MonthlyExpenseSummary>> monthlyExpenseSummary(
  MonthlyExpenseSummaryRef ref, {
  int? year,
  int? limitMonths,
}) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getMonthlyExpenseSummary(
    year: year,
    limitMonths: limitMonths,
  );
}

// Total Expenses Provider (computed)
@riverpod
Future<double> totalExpenses(
  TotalExpensesRef ref, {
  DateTime? startDate,
  DateTime? endDate,
  List<int>? categoryIds,
}) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getTotalExpenses(
    startDate: startDate,
    endDate: endDate,
    categoryIds: categoryIds,
  );
}

// Expense Count Provider (computed)
@riverpod
Future<int> expenseCount(
  ExpenseCountRef ref, {
  DateTime? startDate,
  DateTime? endDate,
  List<int>? categoryIds,
}) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getExpenseCount(
    startDate: startDate,
    endDate: endDate,
    categoryIds: categoryIds,
  );
}

// Average Expense Amount Provider (computed)
@riverpod
Future<double> averageExpenseAmount(
  AverageExpenseAmountRef ref, {
  DateTime? startDate,
  DateTime? endDate,
  List<int>? categoryIds,
}) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getAverageExpenseAmount(
    startDate: startDate,
    endDate: endDate,
    categoryIds: categoryIds,
  );
}

// Similar Expenses Provider (Family)
@riverpod
Future<List<ExpenseEntity>> similarExpenses(
  SimilarExpensesRef ref,
  ExpenseEntity targetExpense,
  {int limit = 5}
) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return await repository.getSimilarExpenses(targetExpense, limit: limit);
}

// Expense Operations Provider (for bulk actions)
@riverpod
class ExpenseOperations extends _$ExpenseOperations {
  @override
  Future<ExpenseOperationResult?> build() async {
    return null; // No initial operation
  }

  /// Import expenses from JSON
  Future<ExpenseOperationResult> importExpenses(List<Map<String, dynamic>> expensesData) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.watch(expenseRepositoryProvider);
      await repository.importExpensesFromJson(expensesData);
      
      // Refresh all expense providers
      ref.invalidate(expensesProvider);
      ref.invalidate(recentExpensesProvider);
      ref.invalidate(expenseStatisticsProvider);
      
      final result = ExpenseOperationResult.success(
        'Successfully imported ${expensesData.length} expenses',
        data: expensesData.length,
      );
      state = AsyncValue.data(result);
      return result;
    } catch (e) {
      final result = ExpenseOperationResult.error('Failed to import expenses: $e');
      state = AsyncValue.data(result);
      return result;
    }
  }

  /// Export expenses to JSON
  Future<ExpenseOperationResult> exportExpenses({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.watch(expenseRepositoryProvider);
      final exportData = await repository.exportExpensesToJson(
        startDate: startDate,
        endDate: endDate,
      );
      
      final result = ExpenseOperationResult.success(
        'Successfully exported ${exportData.length} expenses',
        data: exportData,
      );
      state = AsyncValue.data(result);
      return result;
    } catch (e) {
      final result = ExpenseOperationResult.error('Failed to export expenses: $e');
      state = AsyncValue.data(result);
      return result;
    }
  }

  /// Delete all expenses
  Future<ExpenseOperationResult> deleteAllExpenses() async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.watch(expenseRepositoryProvider);
      await repository.deleteAllExpenses();
      
      // Refresh all providers
      ref.invalidate(expensesProvider);
      ref.invalidate(recentExpensesProvider);
      ref.invalidate(expenseStatisticsProvider);
      
      final result = ExpenseOperationResult.success('All expenses deleted successfully');
      state = AsyncValue.data(result);
      return result;
    } catch (e) {
      final result = ExpenseOperationResult.error('Failed to delete all expenses: $e');
      state = AsyncValue.data(result);
      return result;
    }
  }

  /// Clear operation result
  void clearResult() {
    state = const AsyncValue.data(null);
  }
}

// Quick Stats Provider (for dashboard widgets)
@riverpod
Future<ExpenseQuickStats> expenseQuickStats(ExpenseQuickStatsRef ref) async {
  final repository = ref.watch(expenseRepositoryProvider);
  
  // Get data for different time periods
  final todayTotal = await repository.getTotalExpenses(
    startDate: _getStartOfDay(DateTime.now()),
    endDate: _getEndOfDay(DateTime.now()),
  );
  
  final thisWeekTotal = await repository.getTotalExpenses(
    startDate: _getStartOfWeek(DateTime.now()),
    endDate: DateTime.now(),
  );
  
  final thisMonthTotal = await repository.getTotalExpenses(
    startDate: _getStartOfMonth(DateTime.now()),
    endDate: DateTime.now(),
  );
  
  final recentExpenses = await repository.getRecentExpenses(limit: 5);
  
  return ExpenseQuickStats(
    todayTotal: todayTotal,
    thisWeekTotal: thisWeekTotal,
    thisMonthTotal: thisMonthTotal,
    recentExpensesCount: recentExpenses.length,
    lastExpenseDate: recentExpenses.isNotEmpty ? recentExpenses.first.date : null,
  );
}

// Helper functions for date calculations
DateTime _getStartOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

DateTime _getEndOfDay(DateTime date) {
  return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
}

DateTime _getStartOfWeek(DateTime date) {
  final daysFromMonday = date.weekday - 1;
  return DateTime(date.year, date.month, date.day - daysFromMonday);
}

DateTime _getStartOfMonth(DateTime date) {
  return DateTime(date.year, date.month, 1);
}

/// Expense operation result
class ExpenseOperationResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  const ExpenseOperationResult._({
    required this.isSuccess,
    required this.message,
    this.data,
  });

  factory ExpenseOperationResult.success(String message, {dynamic data}) {
    return ExpenseOperationResult._(
      isSuccess: true,
      message: message,
      data: data,
    );
  }

  factory ExpenseOperationResult.error(String message) {
    return ExpenseOperationResult._(
      isSuccess: false,
      message: message,
    );
  }
}

/// Quick stats model for dashboard
class ExpenseQuickStats {
  final double todayTotal;
  final double thisWeekTotal;
  final double thisMonthTotal;
  final int recentExpensesCount;
  final DateTime? lastExpenseDate;

  const ExpenseQuickStats({
    required this.todayTotal,
    required this.thisWeekTotal,
    required this.thisMonthTotal,
    required this.recentExpensesCount,
    this.lastExpenseDate,
  });

  /// Get formatted amounts
  String get formattedTodayTotal => '\$${todayTotal.toStringAsFixed(2)}';
  String get formattedWeekTotal => '\$${thisWeekTotal.toStringAsFixed(2)}';
  String get formattedMonthTotal => '\$${thisMonthTotal.toStringAsFixed(2)}';
  
  /// Get last expense info
  String get lastExpenseInfo {
    if (lastExpenseDate == null) return 'No recent expenses';
    
    final now = DateTime.now();
    final difference = now.difference(lastExpenseDate!);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    }
  }
}
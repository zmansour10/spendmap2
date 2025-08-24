import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';
// import '../../data/models/expense.dart';

/// Use case for getting expenses with various filtering options
class GetExpensesUseCase {
  final ExpenseRepository _repository;

  const GetExpensesUseCase(this._repository);

  /// Execute the use case
  Future<GetExpensesResult> execute(GetExpensesParams params) async {
    try {
      List<ExpenseEntity> expenses;

      switch (params.type) {
        case ExpenseQueryType.all:
          expenses = await _repository.getAllExpenses();
          break;
        case ExpenseQueryType.today:
          expenses = await _repository.getTodayExpenses();
          break;
        case ExpenseQueryType.thisWeek:
          expenses = await _repository.getThisWeekExpenses();
          break;
        case ExpenseQueryType.thisMonth:
          expenses = await _repository.getThisMonthExpenses();
          break;
        case ExpenseQueryType.thisYear:
          expenses = await _repository.getThisYearExpenses();
          break;
        case ExpenseQueryType.dateRange:
          if (params.startDate == null || params.endDate == null) {
            return GetExpensesResult.failure('Start date and end date required for date range query');
          }
          expenses = await _repository.getExpensesByDateRange(params.startDate!, params.endDate!);
          break;
        case ExpenseQueryType.category:
          if (params.categoryId == null) {
            return GetExpensesResult.failure('Category ID required for category query');
          }
          expenses = await _repository.getExpensesByCategory(params.categoryId!);
          break;
        case ExpenseQueryType.filtered:
          if (params.filter == null) {
            return GetExpensesResult.failure('Filter required for filtered query');
          }
          expenses = await _repository.getFilteredExpenses(params.filter!);
          break;
        case ExpenseQueryType.paginated:
          expenses = await _repository.getExpensesPaginated(
            offset: params.offset ?? 0,
            limit: params.limit ?? 20,
            filter: params.filter,
          );
          break;
        case ExpenseQueryType.recent:
          expenses = await _repository.getRecentExpenses(limit: params.limit ?? 10);
          break;
      }

      // Apply additional business logic if needed
      expenses = _applyBusinessLogic(expenses, params);

      return GetExpensesResult.success(expenses);
    } catch (e) {
      return GetExpensesResult.failure('Failed to get expenses: $e');
    }
  }

  // TODO: Apply business logic to the results
  List<ExpenseEntity> _applyBusinessLogic(List<ExpenseEntity> expenses, GetExpensesParams params) {
    // Apply any additional filtering or business rules
    
    // Example: Hide expenses marked as archived (if we had this feature)
    // expenses = expenses.where((expense) => !expense.isArchived).toList();
    
    // Example: Apply user-specific filters
    if (params.hideSmallExpenses == true) {
      expenses = expenses.where((expense) => expense.amount >= 1.0).toList();
    }

    return expenses;
  }
}

/// Parameters for getting expenses
class GetExpensesParams {
  final ExpenseQueryType type;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? categoryId;
  final ExpenseFilter? filter;
  final int? offset;
  final int? limit;
  final bool? hideSmallExpenses;

  const GetExpensesParams({
    required this.type,
    this.startDate,
    this.endDate,
    this.categoryId,
    this.filter,
    this.offset,
    this.limit,
    this.hideSmallExpenses,
  });

  /// Helper constructors for common queries
  static GetExpensesParams all() => const GetExpensesParams(type: ExpenseQueryType.all);
  
  static GetExpensesParams today() => const GetExpensesParams(type: ExpenseQueryType.today);
  
  static GetExpensesParams thisWeek() => const GetExpensesParams(type: ExpenseQueryType.thisWeek);
  
  static GetExpensesParams thisMonth() => const GetExpensesParams(type: ExpenseQueryType.thisMonth);
  
  static GetExpensesParams dateRange(DateTime start, DateTime end) => GetExpensesParams(
    type: ExpenseQueryType.dateRange,
    startDate: start,
    endDate: end,
  );
  
  static GetExpensesParams category(int categoryId) => GetExpensesParams(
    type: ExpenseQueryType.category,
    categoryId: categoryId,
  );
  
  static GetExpensesParams filtered(ExpenseFilter filter) => GetExpensesParams(
    type: ExpenseQueryType.filtered,
    filter: filter,
  );
  
  static GetExpensesParams paginated({int offset = 0, int limit = 20, ExpenseFilter? filter}) => GetExpensesParams(
    type: ExpenseQueryType.paginated,
    offset: offset,
    limit: limit,
    filter: filter,
  );
  
  static GetExpensesParams recent({int limit = 10}) => GetExpensesParams(
    type: ExpenseQueryType.recent,
    limit: limit,
  );
}

/// Types of expense queries
enum ExpenseQueryType {
  all,
  today,
  thisWeek,
  thisMonth,
  thisYear,
  dateRange,
  category,
  filtered,
  paginated,
  recent,
}

/// Result of getting expenses
class GetExpensesResult {
  final List<ExpenseEntity> expenses;
  final String? error;
  final bool isSuccess;

  const GetExpensesResult._({
    this.expenses = const [],
    this.error,
    required this.isSuccess,
  });

  factory GetExpensesResult.success(List<ExpenseEntity> expenses) {
    return GetExpensesResult._(
      expenses: expenses,
      isSuccess: true,
    );
  }

  factory GetExpensesResult.failure(String error) {
    return GetExpensesResult._(
      error: error,
      isSuccess: false,
    );
  }
}
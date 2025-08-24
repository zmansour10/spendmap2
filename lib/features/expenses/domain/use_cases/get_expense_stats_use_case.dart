import '../repositories/expense_repository.dart';
import '../../data/models/expense.dart';

/// Use case for getting expense statistics and analytics
class GetExpenseStatsUseCase {
  final ExpenseRepository _repository;

  const GetExpenseStatsUseCase(this._repository);

  /// Execute the use case
  Future<GetExpenseStatsResult> execute(GetExpenseStatsParams params) async {
    try {
      // Get basic stats
      final stats = await _repository.getExpenseStats(
        startDate: params.startDate,
        endDate: params.endDate,
        categoryIds: params.categoryIds,
      );

      // Get category breakdown if requested
      List<CategoryExpenseSummary>? categoryBreakdown;
      if (params.includeCategoryBreakdown) {
        categoryBreakdown = await _repository.getCategoryExpenseSummary(
          startDate: params.startDate,
          endDate: params.endDate,
        );
      }

      // Get monthly summary if requested
      List<MonthlyExpenseSummary>? monthlySummary;
      if (params.includeMonthlyBreakdown) {
        monthlySummary = await _repository.getMonthlyExpenseSummary(
          year: params.year,
          limitMonths: params.monthsLimit,
        );
      }

      // Calculate additional insights
      final insights = await _calculateInsights(params);

      return GetExpenseStatsResult.success(
        ExpenseAnalytics(
          stats: stats,
          categoryBreakdown: categoryBreakdown ?? [],
          monthlySummary: monthlySummary ?? [],
          insights: insights,
        ),
      );
    } catch (e) {
      return GetExpenseStatsResult.failure('Failed to get expense stats: $e');
    }
  }

  /// Calculate additional insights
  Future<ExpenseInsights> _calculateInsights(GetExpenseStatsParams params) async {
    try {
      // Compare with previous period
      ExpenseStats? previousPeriodStats;
      if (params.startDate != null && params.endDate != null) {
        final duration = params.endDate!.difference(params.startDate!);
        final previousEnd = params.startDate!.subtract(const Duration(days: 1));
        final previousStart = previousEnd.subtract(duration);
        
        previousPeriodStats = await _repository.getExpenseStats(
          startDate: previousStart,
          endDate: previousEnd,
          categoryIds: params.categoryIds,
        );
      }

      // Get spending trends
      final trends = await _calculateSpendingTrends(params);

      // Get top categories
      final topCategories = await _repository.getCategoryExpenseSummary(
        startDate: params.startDate,
        endDate: params.endDate,
      );

      return ExpenseInsights(
        previousPeriodStats: previousPeriodStats,
        spendingTrends: trends,
        topCategories: topCategories.take(5).toList(),
        averageDailySpending: await _calculateAverageDailySpending(params),
        largestExpense: await _repository.getHighestExpense(
          startDate: params.startDate,
          endDate: params.endDate,
          categoryIds: params.categoryIds,
        ),
      );
    } catch (e) {
      // Return empty insights on error
      return ExpenseInsights.empty();
    }
  }

  // TODO: Calculate spending trends
  Future<List<SpendingTrend>> _calculateSpendingTrends(GetExpenseStatsParams params) async {
    // This could be enhanced to calculate weekly/monthly trends
    // For now, return empty list
    return [];
  }

  /// Calculate average daily spending
  Future<double> _calculateAverageDailySpending(GetExpenseStatsParams params) async {
    if (params.startDate == null || params.endDate == null) {
      return 0.0;
    }

    final total = await _repository.getTotalExpenses(
      startDate: params.startDate,
      endDate: params.endDate,
      categoryIds: params.categoryIds,
    );

    final days = params.endDate!.difference(params.startDate!).inDays + 1;
    return days > 0 ? total / days : 0.0;
  }
}

/// Parameters for getting expense stats
class GetExpenseStatsParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<int>? categoryIds;
  final bool includeCategoryBreakdown;
  final bool includeMonthlyBreakdown;
  final int? year;
  final int? monthsLimit;

  const GetExpenseStatsParams({
    this.startDate,
    this.endDate,
    this.categoryIds,
    this.includeCategoryBreakdown = false,
    this.includeMonthlyBreakdown = false,
    this.year,
    this.monthsLimit,
  });

  /// Helper constructors
  static GetExpenseStatsParams allTime() => const GetExpenseStatsParams();
  
  static GetExpenseStatsParams thisMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1).subtract(const Duration(milliseconds: 1));
    
    return GetExpenseStatsParams(
      startDate: startOfMonth,
      endDate: endOfMonth,
      includeCategoryBreakdown: true,
    );
  }
  
  static GetExpenseStatsParams thisYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year + 1, 1, 1).subtract(const Duration(milliseconds: 1));
    
    return GetExpenseStatsParams(
      startDate: startOfYear,
      endDate: endOfYear,
      includeCategoryBreakdown: true,
      includeMonthlyBreakdown: true,
      year: now.year,
    );
  }
  
  static GetExpenseStatsParams dateRange(DateTime start, DateTime end) => GetExpenseStatsParams(
    startDate: start,
    endDate: end,
    includeCategoryBreakdown: true,
  );
}

/// Comprehensive expense analytics
class ExpenseAnalytics {
  final ExpenseStats stats;
  final List<CategoryExpenseSummary> categoryBreakdown;
  final List<MonthlyExpenseSummary> monthlySummary;
  final ExpenseInsights insights;

  const ExpenseAnalytics({
    required this.stats,
    required this.categoryBreakdown,
    required this.monthlySummary,
    required this.insights,
  });
}

/// Additional expense insights
class ExpenseInsights {
  final ExpenseStats? previousPeriodStats;
  final List<SpendingTrend> spendingTrends;
  final List<CategoryExpenseSummary> topCategories;
  final double averageDailySpending;
  final dynamic largestExpense; // ExpenseEntity or null

  const ExpenseInsights({
    this.previousPeriodStats,
    this.spendingTrends = const [],
    this.topCategories = const [],
    this.averageDailySpending = 0.0,
    this.largestExpense,
  });

  factory ExpenseInsights.empty() => const ExpenseInsights();

  // TODO: Calculate percentage change from previous period
  double? get percentageChange {
    if (previousPeriodStats == null || previousPeriodStats!.totalAmount == 0) {
      return null;
    }
    
    // This would need the current period stats to calculate
    // For now, return null
    return null;
  }
}

/// Spending trend data point
class SpendingTrend {
  final String period; // e.g., "2024-01" or "Week 1"
  final double amount;
  final int expenseCount;

  const SpendingTrend({
    required this.period,
    required this.amount,
    required this.expenseCount,
  });
}

/// Result of getting expense stats
class GetExpenseStatsResult {
  final ExpenseAnalytics? analytics;
  final String? error;
  final bool isSuccess;

  const GetExpenseStatsResult._({
    this.analytics,
    this.error,
    required this.isSuccess,
  });

  factory GetExpenseStatsResult.success(ExpenseAnalytics analytics) {
    return GetExpenseStatsResult._(
      analytics: analytics,
      isSuccess: true,
    );
  }

  factory GetExpenseStatsResult.failure(String error) {
    return GetExpenseStatsResult._(
      error: error,
      isSuccess: false,
    );
  }
}
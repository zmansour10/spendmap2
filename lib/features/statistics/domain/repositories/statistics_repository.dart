import 'package:spendmap2/features/statistics/data/repositories/statistics_repository_impl.dart';

import '../entities/statistics_entity.dart';
import '../entities/chart_data_entity.dart';
import '../entities/budget_entity.dart';

abstract class StatisticsRepository {
  // Expense Statistics
  Future<ExpenseStatistics> getExpenseStatistics({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
  });

  Future<List<CategorySpendingSummary>> getCategorySpendingSummary({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  Future<List<MonthlySpendingTrend>> getMonthlySpendingTrend({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<List<WeeklySpendingTrend>> getWeeklySpendingTrend({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<List<DailySpendingTrend>> getDailySpendingTrend({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Chart Data
  Future<List<PieChartData>> getCategoryPieChartData({
    DateTime? startDate,
    DateTime? endDate,
    int? minCategoryExpenses,
  });

  Future<List<BarChartData>> getMonthlyBarChartData({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<List<LineChartData>> getSpendingTrendLineData({
    DateTime? startDate,
    DateTime? endDate,
    TrendPeriod period,
  });

  // Budget Statistics
  Future<List<BudgetStatus>> getBudgetStatuses({
    DateTime? forMonth,
  });

  Future<BudgetOverview> getBudgetOverview({
    DateTime? forMonth,
  });

  // Comparison Statistics
  Future<PeriodComparison> comparePeriods({
    required DateTime currentStart,
    required DateTime currentEnd,
    required DateTime previousStart,
    required DateTime previousEnd,
  });

  Future<CategoryComparison> compareCategorySpending({
    required int categoryId,
    required DateTime currentStart,
    required DateTime currentEnd,
    required DateTime previousStart,
    required DateTime previousEnd,
  });

  // Insights and Analysis
  Future<List<SpendingInsight>> getSpendingInsights({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<List<CategoryInsight>> getCategoryInsights({
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<List<AnomalyDetection>> detectSpendingAnomalies({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Export and Import
  Future<Map<String, dynamic>> exportStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Cache Management
  Future<void> clearStatisticsCache();
  Future<void> refreshStatisticsCache();
}
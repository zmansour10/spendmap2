import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../domain/entities/statistics_entity.dart';
import '../../domain/entities/chart_data_entity.dart';
import '../../domain/entities/budget_entity.dart';
import '../../data/repositories/statistics_repository_impl.dart';
import '../../../expenses/presentation/providers/expense_provider.dart' hide ExpenseStatistics;
import '../../../categories/presentation/providers/category_provider.dart';

part 'statistics_provider.g.dart';

// Statistics Repository Provider
@riverpod
StatisticsRepository statisticsRepository(StatisticsRepositoryRef ref) {
  final expenseRepository = ref.watch(expenseRepositoryProvider);
  final categoryRepository = ref.watch(categoryRepositoryProvider);
  return StatisticsRepositoryImpl(expenseRepository, categoryRepository);
}

// Expense Statistics Provider
@riverpod
class ExpenseStatisticsData extends _$ExpenseStatisticsData {
  @override
  Future<ExpenseStatistics> build({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
  }) async {
    final repository = ref.watch(statisticsRepositoryProvider);
    return await repository.getExpenseStatistics(
      startDate: startDate,
      endDate: endDate,
      categoryIds: categoryIds,
    );
  }

  /// Refresh statistics
  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// Update date range
  void updateDateRange(DateTime? newStartDate, DateTime? newEndDate) {
    ref.invalidate(expenseStatisticsDataProvider(
      startDate: newStartDate,
      endDate: newEndDate,
      categoryIds: state.valueOrNull != null ? null : null, // Keep current categories
    ));
  }
}

// Category Spending Summary Provider
@riverpod
Future<List<CategorySpendingSummary>> categorySpendingSummary(
  CategorySpendingSummaryRef ref, {
  DateTime? startDate,
  DateTime? endDate,
  int? limit,
}) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return await repository.getCategorySpendingSummary(
    startDate: startDate,
    endDate: endDate,
    limit: limit,
  );
}

// Monthly Spending Trend Provider
@riverpod
Future<List<MonthlySpendingTrend>> monthlySpendingTrend(
  MonthlySpendingTrendRef ref, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return await repository.getMonthlySpendingTrend(
    startDate: startDate,
    endDate: endDate,
  );
}

// Chart Data Providers
@riverpod
Future<List<PieChartData>> categoryPieChartData(
  CategoryPieChartDataRef ref, {
  DateTime? startDate,
  DateTime? endDate,
  int? minCategoryExpenses,
}) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return await repository.getCategoryPieChartData(
    startDate: startDate,
    endDate: endDate,
    minCategoryExpenses: minCategoryExpenses,
  );
}

@riverpod
Future<List<BarChartData>> monthlyBarChartData(
  MonthlyBarChartDataRef ref, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return await repository.getMonthlyBarChartData(
    startDate: startDate,
    endDate: endDate,
  );
}

@riverpod
Future<List<LineChartData>> spendingTrendLineData(
  SpendingTrendLineDataRef ref, {
  DateTime? startDate,
  DateTime? endDate,
  TrendPeriod period = TrendPeriod.daily,
}) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return await repository.getSpendingTrendLineData(
    startDate: startDate,
    endDate: endDate,
    period: period,
  );
}

// Period Comparison Provider
@riverpod
Future<PeriodComparison> periodComparison(
  PeriodComparisonRef ref, {
  required DateTime currentStart,
  required DateTime currentEnd,
  required DateTime previousStart,
  required DateTime previousEnd,
}) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return await repository.comparePeriods(
    currentStart: currentStart,
    currentEnd: currentEnd,
    previousStart: previousStart,
    previousEnd: previousEnd,
  );
}

// Spending Insights Provider
@riverpod
Future<List<SpendingInsight>> spendingInsights(
  SpendingInsightsRef ref, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return await repository.getSpendingInsights(
    startDate: startDate,
    endDate: endDate,
  );
}

// Anomaly Detection Provider
@riverpod
Future<List<AnomalyDetection>> spendingAnomalies(
  SpendingAnomaliesRef ref, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return await repository.detectSpendingAnomalies(
    startDate: startDate,
    endDate: endDate,
  );
}

// Quick Stats Providers for Dashboard
@riverpod
Future<DashboardStats> dashboardStats(DashboardStatsRef ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  final now = DateTime.now();
  
  // Get stats for different periods
  final todayStats = await repository.getExpenseStatistics(
    startDate: DateTime(now.year, now.month, now.day),
    endDate: now,
  );
  
  final thisWeekStats = await repository.getExpenseStatistics(
    startDate: _getWeekStart(now),
    endDate: now,
  );
  
  final thisMonthStats = await repository.getExpenseStatistics(
    startDate: DateTime(now.year, now.month, 1),
    endDate: now,
  );
  
  final topCategories = await repository.getCategorySpendingSummary(
    startDate: DateTime(now.year, now.month, 1),
    endDate: now,
    limit: 5,
  );

  return DashboardStats(
    todayTotal: todayStats.totalAmount,
    todayCount: todayStats.totalExpenses,
    weekTotal: thisWeekStats.totalAmount,
    weekCount: thisWeekStats.totalExpenses,
    monthTotal: thisMonthStats.totalAmount,
    monthCount: thisMonthStats.totalExpenses,
    topCategories: topCategories,
    lastUpdated: DateTime.now(),
  );
}

// Statistics Filter State Provider
@riverpod
class StatisticsFilter extends _$StatisticsFilter {
  @override
  StatisticsFilterState build() {
    return StatisticsFilterState.thisMonth();
  }

  void setDateRange(DateTime startDate, DateTime endDate) {
    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
      period: StatisticsPeriod.custom,
    );
  }

  void setPeriod(StatisticsPeriod period) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    switch (period) {
      case StatisticsPeriod.today:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case StatisticsPeriod.thisWeek:
        startDate = _getWeekStart(now);
        break;
      case StatisticsPeriod.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case StatisticsPeriod.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        startDate = lastMonth;
        endDate = DateTime(now.year, now.month, 1).subtract(const Duration(days: 1));
        break;
      case StatisticsPeriod.thisYear:
        startDate = DateTime(now.year, 1, 1);
        break;
      case StatisticsPeriod.lastYear:
        startDate = DateTime(now.year - 1, 1, 1);
        endDate = DateTime(now.year - 1, 12, 31);
        break;
        
      case StatisticsPeriod.custom:
        // Keep existing dates
        return;
    }

    state = state.copyWith(
      startDate: startDate,
      endDate: endDate,
      period: period,
    );
  }

  void setCategoryFilter(List<int>? categoryIds) {
    state = state.copyWith(categoryIds: categoryIds);
  }

  void setChartType(ChartType chartType) {
    state = state.copyWith(chartType: chartType);
  }
}

// Helper function
DateTime _getWeekStart(DateTime date) {
  final daysFromMonday = date.weekday - 1;
  return DateTime(date.year, date.month, date.day - daysFromMonday);
}

/// Dashboard statistics model
class DashboardStats {
  final double todayTotal;
  final int todayCount;
  final double weekTotal;
  final int weekCount;
  final double monthTotal;
  final int monthCount;
  final List<CategorySpendingSummary> topCategories;
  final DateTime lastUpdated;

  const DashboardStats({
    required this.todayTotal,
    required this.todayCount,
    required this.weekTotal,
    required this.weekCount,
    required this.monthTotal,
    required this.monthCount,
    required this.topCategories,
    required this.lastUpdated,
 });

 String get formattedTodayTotal => '\$${todayTotal.toStringAsFixed(2)}';
 String get formattedWeekTotal => '\$${weekTotal.toStringAsFixed(2)}';
 String get formattedMonthTotal => '\$${monthTotal.toStringAsFixed(2)}';
 
 double get weekDailyAverage => weekTotal / 7;
 double get monthDailyAverage => monthTotal / DateTime.now().day;
 
 String get formattedWeekDailyAverage => '\$${weekDailyAverage.toStringAsFixed(2)}';
 String get formattedMonthDailyAverage => '\$${monthDailyAverage.toStringAsFixed(2)}';
}

// Now using StatisticsFilterState, StatisticsPeriod, and ChartType from statistics_entity.dart

// Filtered Statistics Provider (based on current filter)
@riverpod
Future<ExpenseStatistics> filteredExpenseStatistics(FilteredExpenseStatisticsRef ref) async {
 final filter = ref.watch(statisticsFilterProvider);
 final repository = ref.watch(statisticsRepositoryProvider);
 
 return await repository.getExpenseStatistics(
   startDate: filter.startDate,
   endDate: filter.endDate,
   categoryIds: filter.categoryIds,
 );
}

@riverpod
Future<List<CategorySpendingSummary>> filteredCategorySpending(FilteredCategorySpendingRef ref) async {
 final filter = ref.watch(statisticsFilterProvider);
 final repository = ref.watch(statisticsRepositoryProvider);
 
 return await repository.getCategorySpendingSummary(
   startDate: filter.startDate,
   endDate: filter.endDate,
 );
}

@riverpod
Future<List<dynamic>> filteredChartData(FilteredChartDataRef ref) async {
 final filter = ref.watch(statisticsFilterProvider);
 final repository = ref.watch(statisticsRepositoryProvider);
 
 switch (filter.chartType) {
   case ChartType.pie:
     return await repository.getCategoryPieChartData(
       startDate: filter.startDate,
       endDate: filter.endDate,
     );
   case ChartType.bar:
     return await repository.getMonthlyBarChartData(
       startDate: filter.startDate,
       endDate: filter.endDate,
     );
   case ChartType.line:
     return await repository.getSpendingTrendLineData(
       startDate: filter.startDate,
       endDate: filter.endDate,
       period: _getTrendPeriodFromFilter(filter),
     );
     
 }
}

TrendPeriod _getTrendPeriodFromFilter(StatisticsFilterState filter) {
 final daysDifference = filter.endDate.difference(filter.startDate).inDays;
 
 if (daysDifference <= 7) {
   return TrendPeriod.daily;
 } else if (daysDifference <= 84) {
   return TrendPeriod.weekly;
 } else if (daysDifference <= 365) {
   return TrendPeriod.monthly;
 } else {
   return TrendPeriod.yearly;
 }
}

// Statistics Export Provider
@riverpod
class StatisticsExport extends _$StatisticsExport {
 @override
 Future<StatisticsExportResult?> build() async {
   return null; // No initial export
 }

 /// Export current statistics
 Future<StatisticsExportResult> exportCurrentStatistics() async {
   final filter = ref.read(statisticsFilterProvider);
   final repository = ref.read(statisticsRepositoryProvider);
   
   state = const AsyncValue.loading();

   try {
     final exportData = await repository.exportStatistics(
       startDate: filter.startDate,
       endDate: filter.endDate,
     );

     final result = StatisticsExportResult.success(
       'Statistics exported successfully',
       data: exportData,
     );
     
     state = AsyncValue.data(result);
     return result;
   } catch (e) {
     final result = StatisticsExportResult.error('Failed to export statistics: $e');
     state = AsyncValue.data(result);
     return result;
   }
 }

 /// Clear export result
 void clearResult() {
   state = const AsyncValue.data(null);
 }
}

// Statistics Cache Management Provider
@riverpod
class StatisticsCache extends _$StatisticsCache {
 @override
 Future<StatisticsCacheResult?> build() async {
   return null;
 }

 /// Clear statistics cache
 Future<StatisticsCacheResult> clearCache() async {
   state = const AsyncValue.loading();
   
   try {
     final repository = ref.read(statisticsRepositoryProvider);
     await repository.clearStatisticsCache();
     
     // Invalidate all statistics providers to force refresh
     ref.invalidate(expenseStatisticsDataProvider);
     ref.invalidate(categorySpendingSummaryProvider);
     ref.invalidate(monthlySpendingTrendProvider);
     ref.invalidate(dashboardStatsProvider);
     
     final result = StatisticsCacheResult.success('Cache cleared successfully');
     state = AsyncValue.data(result);
     return result;
   } catch (e) {
     final result = StatisticsCacheResult.error('Failed to clear cache: $e');
     state = AsyncValue.data(result);
     return result;
   }
 }

 /// Refresh statistics cache
 Future<StatisticsCacheResult> refreshCache() async {
   state = const AsyncValue.loading();
   
   try {
     final repository = ref.read(statisticsRepositoryProvider);
     await repository.refreshStatisticsCache();
     
     // Invalidate providers to trigger refresh
     ref.invalidate(expenseStatisticsDataProvider);
     ref.invalidate(dashboardStatsProvider);
     
     final result = StatisticsCacheResult.success('Cache refreshed successfully');
     state =  AsyncValue.data(result);
     return result;
   } catch (e) {
     final result = StatisticsCacheResult.error('Failed to refresh cache: $e');
     state = AsyncValue.data(result);
     return result;
   }
 }

 /// Clear cache result
 void clearResult() {
   state = const AsyncValue.data(null);
 }
}

// Comparison Providers
@riverpod
Future<PeriodComparison> thisMonthVsLastMonth(ThisMonthVsLastMonthRef ref) async {
 final now = DateTime.now();
 final thisMonthStart = DateTime(now.year, now.month, 1);
 final lastMonthStart = DateTime(now.year, now.month - 1, 1);
 final lastMonthEnd = thisMonthStart.subtract(const Duration(days: 1));

 return ref.watch(periodComparisonProvider(
   currentStart: thisMonthStart,
   currentEnd: now,
   previousStart: lastMonthStart,
   previousEnd: lastMonthEnd,
 ).future);
}

@riverpod
Future<PeriodComparison> thisWeekVsLastWeek(ThisWeekVsLastWeekRef ref) async {
 final now = DateTime.now();
 final thisWeekStart = _getWeekStart(now);
 final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
 final lastWeekEnd = thisWeekStart.subtract(const Duration(days: 1));

 return ref.watch(periodComparisonProvider(
   currentStart: thisWeekStart,
   currentEnd: now,
   previousStart: lastWeekStart,
   previousEnd: lastWeekEnd,
 ).future);
}

// Top Categories Provider (for quick insights)
@riverpod
Future<List<CategorySpendingSummary>> topSpendingCategories(
 TopSpendingCategoriesRef ref, {
 int limit = 5,
 DateTime? startDate,
 DateTime? endDate,
}) async {
 final summaries = await ref.watch(categorySpendingSummaryProvider(
   startDate: startDate,
   endDate: endDate,
 ).future);
 
 return summaries.take(limit).toList();
}

// Additional missing providers that the statistics screen references
@riverpod
Future<List<CategoryInsight>> categoryInsights(
  CategoryInsightsRef ref, {
  DateTime? startDate, 
  DateTime? endDate,
}) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return await repository.getCategoryInsights(
    startDate: startDate,
    endDate: endDate,
  );
}

@riverpod
Future<List<WeeklySpendingTrend>> weeklySpendingTrend(
  WeeklySpendingTrendRef ref, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return await repository.getWeeklySpendingTrend(
    startDate: startDate,
    endDate: endDate,
  );
}

/// Statistics export result
class StatisticsExportResult {
 final bool isSuccess;
 final String message;
 final Map<String, dynamic>? data;

 const StatisticsExportResult._({
   required this.isSuccess,
   required this.message,
   this.data,
 });

 factory StatisticsExportResult.success(String message, {Map<String, dynamic>? data}) {
   return StatisticsExportResult._(
     isSuccess: true,
     message: message,
     data: data,
   );
 }

 factory StatisticsExportResult.error(String message) {
   return StatisticsExportResult._(
     isSuccess: false,
     message: message,
   );
 }
}

/// Statistics cache result
class StatisticsCacheResult {
 final bool isSuccess;
 final String message;

 const StatisticsCacheResult._({
   required this.isSuccess,
   required this.message,
 });

 factory StatisticsCacheResult.success(String message) {
   return StatisticsCacheResult._(isSuccess: true, message: message);
 }

 factory StatisticsCacheResult.error(String message) {
   return StatisticsCacheResult._(isSuccess: false, message: message);
 }
}
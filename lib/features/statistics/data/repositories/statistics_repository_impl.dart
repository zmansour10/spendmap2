import '../../domain/repositories/statistics_repository.dart';
import '../../domain/entities/statistics_entity.dart';
import '../../domain/entities/chart_data_entity.dart';
import '../../domain/entities/budget_entity.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import 'package:flutter/material.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final ExpenseRepository _expenseRepository;
  final CategoryRepository _categoryRepository;
  
  // Cache for expensive calculations
  final Map<String, dynamic> _cache = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  StatisticsRepositoryImpl(this._expenseRepository, this._categoryRepository);

  @override
  Future<ExpenseStatistics> getExpenseStatistics({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
  }) async {
    final cacheKey = 'expense_stats_${startDate?.toIso8601String()}_${endDate?.toIso8601String()}_${categoryIds?.join(',')}';
    
    if (_cache.containsKey(cacheKey) && _isCacheValid(cacheKey)) {
      return _cache[cacheKey];
    }

    final expenses = await _expenseRepository.getExpensesByDateRange(
      startDate ?? DateTime(2000),
      endDate ?? DateTime.now(),
    );

    // Filter by categories if specified
    final filteredExpenses = categoryIds != null
        ? expenses.where((expense) => categoryIds.contains(expense.categoryId)).toList()
        : expenses;

    if (filteredExpenses.isEmpty) {
      const result = ExpenseStatistics(
        totalAmount: 0.0,
        totalExpenses: 0,
        averageExpense: 0.0,
        highestExpense: 0.0,
        lowestExpense: 0.0,
        categoryTotals: {},
        categoryCounts: {},
      );
      _cache[cacheKey] = result;
      _cache['${cacheKey}_timestamp'] = DateTime.now();
      return result;
    }

    final amounts = filteredExpenses.map((e) => e.amount).toList();
    final totalAmount = amounts.reduce((a, b) => a + b);
    final averageExpense = totalAmount / filteredExpenses.length;
    final highestExpense = amounts.reduce((a, b) => a > b ? a : b);
    final lowestExpense = amounts.reduce((a, b) => a < b ? a : b);

    // Calculate category breakdowns
    final categoryTotals = <String, double>{};
    final categoryCounts = <String, int>{};
    final categories = await _categoryRepository.getAllCategories();
    final categoryMap = {for (var cat in categories) cat.id: cat.name};

    for (final expense in filteredExpenses) {
      final categoryName = categoryMap[expense.categoryId] ?? 'Unknown';
      categoryTotals[categoryName] = (categoryTotals[categoryName] ?? 0.0) + expense.amount;
      categoryCounts[categoryName] = (categoryCounts[categoryName] ?? 0) + 1;
    }

    final result = ExpenseStatistics(
      totalAmount: totalAmount,
      totalExpenses: filteredExpenses.length,
      averageExpense: averageExpense,
      highestExpense: highestExpense,
      lowestExpense: lowestExpense,
      startDate: startDate,
      endDate: endDate,
      categoryTotals: categoryTotals,
      categoryCounts: categoryCounts,
    );

    _cache[cacheKey] = result;
    _cache['${cacheKey}_timestamp'] = DateTime.now();
    return result;
  }

  @override
  Future<List<CategorySpendingSummary>> getCategorySpendingSummary({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    final expenses = await _expenseRepository.getExpensesByDateRange(
      startDate ?? DateTime(2000),
      endDate ?? DateTime.now(),
    );

    final categories = await _categoryRepository.getAllCategories();
    final categoryMap = {for (var cat in categories) cat.id: cat};

    // Group expenses by category
    final categoryGroups = <int, List<dynamic>>{};
    for (final expense in expenses) {
      categoryGroups.putIfAbsent(expense.categoryId, () => []).add(expense);
    }

    final totalAmount = expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);

    final summaries = <CategorySpendingSummary>[];
    
    for (final entry in categoryGroups.entries) {
      final categoryId = entry.key;
      final categoryExpenses = entry.value;
      final category = categoryMap[categoryId];
      
      if (category == null) continue;

      final categoryTotal = categoryExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
      final percentage = totalAmount > 0 ? (categoryTotal / totalAmount) * 100 : 0.0;
      final averageExpense = categoryTotal / categoryExpenses.length;

      summaries.add(CategorySpendingSummary(
        categoryId: categoryId,
        categoryName: category.name,
        categoryIconCode: category.iconCode,
        categoryColorValue: category.colorValue,
        totalAmount: categoryTotal,
        expenseCount: categoryExpenses.length,
        percentage: percentage,
        averageExpense: averageExpense,
      ));
    }

    // Sort by total amount descending
    summaries.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    if (limit != null && limit > 0) {
      return summaries.take(limit).toList();
    }

    return summaries;
  }

  @override
  Future<List<PieChartData>> getCategoryPieChartData({
    DateTime? startDate,
    DateTime? endDate,
    int? minCategoryExpenses,
  }) async {
    final summaries = await getCategorySpendingSummary(
      startDate: startDate,
      endDate: endDate,
    );

    final filteredSummaries = minCategoryExpenses != null
        ? summaries.where((s) => s.expenseCount >= minCategoryExpenses).toList()
        : summaries;

    return filteredSummaries.map((summary) {
      return PieChartData(
        label: summary.categoryName,
        value: summary.totalAmount,
        color: Color(summary.categoryColorValue),
        metadata: {
          'categoryId': summary.categoryId,
          'expenseCount': summary.expenseCount,
          'percentage': summary.percentage,
          'averageExpense': summary.averageExpense,
        },
      );
    }).toList();
  }

  @override
  Future<List<MonthlySpendingTrend>> getMonthlySpendingTrend({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final expenses = await _expenseRepository.getExpensesByDateRange(
      startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      endDate ?? DateTime.now(),
    );

    // Group expenses by month
    final monthlyGroups = <String, List<dynamic>>{};
    for (final expense in expenses) {
      final monthKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}';
      monthlyGroups.putIfAbsent(monthKey, () => []).add(expense);
    }

    final trends = <MonthlySpendingTrend>[];
    
    for (final entry in monthlyGroups.entries) {
      final monthKey = entry.key;
      final monthExpenses = entry.value;
      final parts = monthKey.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      
      final totalAmount = monthExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
      
      // Category breakdown for this month
      final categoryBreakdown = <int, double>{};
      for (final expense in monthExpenses) {
        categoryBreakdown[expense.categoryId] = 
            (categoryBreakdown[expense.categoryId] ?? 0.0) + expense.amount;
      }

      trends.add(MonthlySpendingTrend(
        month: DateTime(year, month),
        totalAmount: totalAmount,
        expenseCount: monthExpenses.length,
        categoryBreakdown: categoryBreakdown,
      ));
    }

    // Sort by date
    trends.sort((a, b) => a.month.compareTo(b.month));
    return trends;
  }

  @override
  Future<List<LineChartData>> getSpendingTrendLineData({
    DateTime? startDate,
    DateTime? endDate,
    TrendPeriod period = TrendPeriod.daily,
  }) async {
    switch (period) {
      case TrendPeriod.daily:
        return _getDailyTrendLineData(startDate, endDate);
      case TrendPeriod.weekly:
        return _getWeeklyTrendLineData(startDate, endDate);
      case TrendPeriod.monthly:
        return _getMonthlyTrendLineData(startDate, endDate);
      case TrendPeriod.yearly:
        return _getYearlyTrendLineData(startDate, endDate);
    }
  }

  Future<List<LineChartData>> _getDailyTrendLineData(DateTime? startDate, DateTime? endDate) async {
    final expenses = await _expenseRepository.getExpensesByDateRange(
      startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      endDate ?? DateTime.now(),
    );

    // Group expenses by date
    final dailyGroups = <String, List<dynamic>>{};
    for (final expense in expenses) {
      final dateKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';
      dailyGroups.putIfAbsent(dateKey, () => []).add(expense);
    }

    final lineData = <LineChartData>[];
    
    for (final entry in dailyGroups.entries) {
      final dateKey = entry.key;
      final dayExpenses = entry.value;
      final parts = dateKey.split('-');
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      
      final totalAmount = dayExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);

     lineData.add(LineChartData(
       date: DateTime(year, month, day),
       value: totalAmount,
       metadata: {
         'expenseCount': dayExpenses.length,
         'dateKey': dateKey,
       },
     ));
   }

   // Sort by date
   lineData.sort((a, b) => a.date.compareTo(b.date));
   return lineData;
 }

 Future<List<LineChartData>> _getWeeklyTrendLineData(DateTime? startDate, DateTime? endDate) async {
   final expenses = await _expenseRepository.getExpensesByDateRange(
     startDate ?? DateTime.now().subtract(const Duration(days: 84)), // 12 weeks
     endDate ?? DateTime.now(),
   );

   // Group expenses by week
   final weeklyGroups = <String, List<dynamic>>{};
   for (final expense in expenses) {
     final weekStart = _getWeekStart(expense.date);
     final weekKey = weekStart.toIso8601String().split('T')[0];
     weeklyGroups.putIfAbsent(weekKey, () => []).add(expense);
   }

   final lineData = <LineChartData>[];
   
   for (final entry in weeklyGroups.entries) {
     final weekKey = entry.key;
     final weekExpenses = entry.value;
     final weekStart = DateTime.parse(weekKey);
     
     final totalAmount = weekExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);

     lineData.add(LineChartData(
       date: weekStart,
       value: totalAmount,
       label: 'Week of ${weekStart.month}/${weekStart.day}',
       metadata: {
         'expenseCount': weekExpenses.length,
         'weekEnd': weekStart.add(const Duration(days: 6)),
       },
     ));
   }

   lineData.sort((a, b) => a.date.compareTo(b.date));
   return lineData;
 }

 Future<List<LineChartData>> _getMonthlyTrendLineData(DateTime? startDate, DateTime? endDate) async {
   final monthlyTrends = await getMonthlySpendingTrend(
     startDate: startDate,
     endDate: endDate,
   );

   return monthlyTrends.map((trend) {
     return LineChartData(
       date: trend.month,
       value: trend.totalAmount,
       label: trend.monthLabel,
       metadata: {
         'expenseCount': trend.expenseCount,
         'categoryBreakdown': trend.categoryBreakdown,
       },
     );
   }).toList();
 }

 Future<List<LineChartData>> _getYearlyTrendLineData(DateTime? startDate, DateTime? endDate) async {
   final expenses = await _expenseRepository.getExpensesByDateRange(
     startDate ?? DateTime.now().subtract(const Duration(days: 1095)), // 3 years
     endDate ?? DateTime.now(),
   );

   // Group expenses by year
   final yearlyGroups = <int, List<dynamic>>{};
   for (final expense in expenses) {
     yearlyGroups.putIfAbsent(expense.date.year, () => []).add(expense);
   }

   final lineData = <LineChartData>[];
   
   for (final entry in yearlyGroups.entries) {
     final year = entry.key;
     final yearExpenses = entry.value;
     
     final totalAmount = yearExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);

     lineData.add(LineChartData(
       date: DateTime(year, 1, 1),
       value: totalAmount,
       label: year.toString(),
       metadata: {
         'expenseCount': yearExpenses.length,
         'year': year,
       },
     ));
   }

   lineData.sort((a, b) => a.date.compareTo(b.date));
   return lineData;
 }

 @override
 Future<PeriodComparison> comparePeriods({
   required DateTime currentStart,
   required DateTime currentEnd,
   required DateTime previousStart,
   required DateTime previousEnd,
 }) async {
   final currentExpenses = await _expenseRepository.getExpensesByDateRange(currentStart, currentEnd);
   final previousExpenses = await _expenseRepository.getExpensesByDateRange(previousStart, previousEnd);

   final currentTotal = currentExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
   final previousTotal = previousExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
   
   final amountChange = currentTotal - previousTotal;
   final percentageChange = previousTotal > 0 ? (amountChange / previousTotal) * 100 : 0.0;

   return PeriodComparison(
     currentPeriodTotal: currentTotal,
     previousPeriodTotal: previousTotal,
     currentPeriodCount: currentExpenses.length,
     previousPeriodCount: previousExpenses.length,
     amountChange: amountChange,
     percentageChange: percentageChange,
     isIncrease: amountChange > 0,
   );
 }

 @override
 Future<List<SpendingInsight>> getSpendingInsights({
   DateTime? startDate,
   DateTime? endDate,
 }) async {
   final insights = <SpendingInsight>[];
   
   // Get current period stats
   final currentStats = await getExpenseStatistics(
     startDate: startDate,
     endDate: endDate,
   );

   // Compare with previous period
   final periodLength = (endDate ?? DateTime.now()).difference(startDate ?? DateTime.now().subtract(const Duration(days: 30))).inDays;
   final previousStart = (startDate ?? DateTime.now().subtract(const Duration(days: 30))).subtract(Duration(days: periodLength));
   final previousEnd = startDate ?? DateTime.now().subtract(const Duration(days: 30));
   
   final comparison = await comparePeriods(
     currentStart: startDate ?? DateTime.now().subtract(const Duration(days: 30)),
     currentEnd: endDate ?? DateTime.now(),
     previousStart: previousStart,
     previousEnd: previousEnd,
   );

   // Generate insights based on data analysis
   if (comparison.percentageChange > 20) {
     insights.add(SpendingInsight(
       title: 'Spending Increase Alert',
       description: 'Your spending has increased by ${comparison.formattedPercentageChange} compared to the previous period.',
       type: InsightType.trendAlert,
       priority: InsightPriority.high,
       data: {'comparison': comparison},
     ));
   }

   if (comparison.percentageChange < -20) {
     insights.add(SpendingInsight(
       title: 'Great Savings!',
       description: 'You\'ve reduced your spending by ${comparison.formattedPercentageChange} compared to the previous period.',
       type: InsightType.savingsOpportunity,
       priority: InsightPriority.medium,
       data: {'comparison': comparison},
     ));
   }

   // Category-based insights
   final categoryInsights = await _generateCategoryInsights(startDate, endDate);
   insights.addAll(categoryInsights.map((ci) => SpendingInsight(
     title: ci.insight,
     description: 'Analysis for ${ci.categoryName}',
     type: InsightType.categoryAnomaly,
     priority: InsightPriority.medium,
     data: ci.data,
   )));

   return insights;
 }

 @override
 Future<List<CategoryInsight>> getCategoryInsights({
   DateTime? startDate,
   DateTime? endDate,
 }) async {
   return await _generateCategoryInsights(startDate, endDate);
 }

 Future<List<CategoryInsight>> _generateCategoryInsights(DateTime? startDate, DateTime? endDate) async {
   final insights = <CategoryInsight>[];
   final summaries = await getCategorySpendingSummary(startDate: startDate, endDate: endDate);
   
   for (final summary in summaries.take(5)) { // Top 5 categories
     if (summary.percentage > 40) {
       insights.add(CategoryInsight(
         categoryId: summary.categoryId,
         categoryName: summary.categoryName,
         insight: '${summary.categoryName} represents ${summary.formattedPercentage} of your spending',
         type: InsightType.spendingPattern,
         data: {
           'percentage': summary.percentage,
           'amount': summary.totalAmount,
           'suggestion': 'Consider reviewing expenses in this category',
         },
       ));
     }
   }

   return insights;
 }

 @override
 Future<List<AnomalyDetection>> detectSpendingAnomalies({
   DateTime? startDate,
   DateTime? endDate,
 }) async {
   final anomalies = <AnomalyDetection>[];
   final lineData = await getSpendingTrendLineData(
     startDate: startDate,
     endDate: endDate,
     period: TrendPeriod.daily,
   );

   if (lineData.length < 7) return anomalies; // Need enough data

   // Calculate moving average and detect outliers
   for (int i = 3; i < lineData.length - 3; i++) {
     final current = lineData[i];
     final surrounding = lineData.sublist(i - 3, i + 4);
     final average = surrounding.fold<double>(0.0, (sum, data) => sum + data.value) / surrounding.length;
     
     final deviation = (current.value - average).abs();
     final threshold = average * 0.5; // 50% deviation threshold

     if (deviation > threshold) {
       anomalies.add(AnomalyDetection(
         date: current.date,
         expectedAmount: average,
         actualAmount: current.value,
         deviation: deviation,
         description: current.value > average 
             ? 'Unusually high spending detected'
             : 'Unusually low spending detected',
         type: current.value > average 
             ? AnomalyType.unusuallyHigh 
             : AnomalyType.unusuallyLow,
       ));
     }
   }

   return anomalies;
 }

 @override
 Future<List<BudgetStatus>> getBudgetStatuses({DateTime? forMonth}) async {
   // This would typically integrate with a budget management system
   // For now, return empty list as budgets aren't implemented yet
   return [];
 }

 @override
 Future<BudgetOverview> getBudgetOverview({DateTime? forMonth}) async {
   // This would typically integrate with a budget management system
   // For now, return a basic overview
   return const BudgetOverview(
     totalBudget: 0.0,
     totalSpent: 0.0,
     totalRemaining: 0.0,
     overallPercentageUsed: 0.0,
     categoriesOverBudget: 0,
     categoriesNearBudget: 0,
     totalCategories: 0,
     periodStart: null, // A value of type 'Null' can't be assigned to a parameter of type 'DateTime' in a const constructor.
     periodEnd: null,
     categoryStatuses: [],
   );
 }

 @override
 Future<List<WeeklySpendingTrend>> getWeeklySpendingTrend({
   DateTime? startDate,
   DateTime? endDate,
 }) async {
   final expenses = await _expenseRepository.getExpensesByDateRange(
     startDate ?? DateTime.now().subtract(const Duration(days: 84)),
     endDate ?? DateTime.now(),
   );

   // Group expenses by week
   final weeklyGroups = <String, List<dynamic>>{};
   for (final expense in expenses) {
     final weekStart = _getWeekStart(expense.date);
     final weekKey = weekStart.toIso8601String().split('T')[0];
     weeklyGroups.putIfAbsent(weekKey, () => []).add(expense);
   }

   final trends = <WeeklySpendingTrend>[];
   
   for (final entry in weeklyGroups.entries) {
     final weekKey = entry.key;
     final weekExpenses = entry.value;
     final weekStart = DateTime.parse(weekKey);
     final weekEnd = weekStart.add(const Duration(days: 6));
     
     final totalAmount = weekExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
     
     // Category breakdown for this week
     final categoryBreakdown = <int, double>{};
     for (final expense in weekExpenses) {
       categoryBreakdown[expense.categoryId] = 
           (categoryBreakdown[expense.categoryId] ?? 0.0) + expense.amount;
     }

     trends.add(WeeklySpendingTrend(
       weekStart: weekStart,
       weekEnd: weekEnd,
       totalAmount: totalAmount,
       expenseCount: weekExpenses.length,
       categoryBreakdown: categoryBreakdown,
     ));
   }

   trends.sort((a, b) => a.weekStart.compareTo(b.weekStart));
   return trends;
 }

 @override
 Future<List<DailySpendingTrend>> getDailySpendingTrend({
   DateTime? startDate,
   DateTime? endDate,
 }) async {
   final expenses = await _expenseRepository.getExpensesByDateRange(
     startDate ?? DateTime.now().subtract(const Duration(days: 30)),
     endDate ?? DateTime.now(),
   );

   // Group expenses by date
   final dailyGroups = <String, List<dynamic>>{};
   for (final expense in expenses) {
     final dateKey = '${expense.date.year}-${expense.date.month.toString().padLeft(2, '0')}-${expense.date.day.toString().padLeft(2, '0')}';
     dailyGroups.putIfAbsent(dateKey, () => []).add(expense);
   }

   final trends = <DailySpendingTrend>[];
   
   for (final entry in dailyGroups.entries) {
     final dateKey = entry.key;
     final dayExpenses = entry.value;
     final parts = dateKey.split('-');
     final year = int.parse(parts[0]);
     final month = int.parse(parts[1]);
     final day = int.parse(parts[2]);
     
     final totalAmount = dayExpenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
     
     // Category breakdown for this day
     final categoryBreakdown = <int, double>{};
     for (final expense in dayExpenses) {
       categoryBreakdown[expense.categoryId] = 
           (categoryBreakdown[expense.categoryId] ?? 0.0) + expense.amount;
     }

     trends.add(DailySpendingTrend(
       date: DateTime(year, month, day),
       totalAmount: totalAmount,
       expenseCount: dayExpenses.length,
       categoryBreakdown: categoryBreakdown,
     ));
   }

   trends.sort((a, b) => a.date.compareTo(b.date));
   return trends;
 }

 @override
 Future<List<BarChartData>> getMonthlyBarChartData({
   DateTime? startDate,
   DateTime? endDate,
 }) async {
   final monthlyTrends = await getMonthlySpendingTrend(
     startDate: startDate,
     endDate: endDate,
   );

   return monthlyTrends.map((trend) {
     return BarChartData(
       label: trend.monthLabel,
       value: trend.totalAmount,
       color: Colors.blue,
       date: trend.month,
       metadata: {
         'expenseCount': trend.expenseCount,
         'categoryBreakdown': trend.categoryBreakdown,
       },
     );
   }).toList();
 }

 @override
 Future<CategoryComparison> compareCategorySpending({
   required int categoryId,
   required DateTime currentStart,
   required DateTime currentEnd,
   required DateTime previousStart,
   required DateTime previousEnd,
 }) async {
   final currentExpenses = await _expenseRepository.getExpensesByCategory(categoryId);
   final currentFiltered = currentExpenses
       .where((e) => e.date.isAfter(currentStart.subtract(const Duration(days: 1))) && 
                    e.date.isBefore(currentEnd.add(const Duration(days: 1))))
       .toList();

   final previousFiltered = currentExpenses
       .where((e) => e.date.isAfter(previousStart.subtract(const Duration(days: 1))) && 
                    e.date.isBefore(previousEnd.add(const Duration(days: 1))))
       .toList();

   final currentTotal = currentFiltered.fold<double>(0.0, (sum, expense) => sum + expense.amount);
   final previousTotal = previousFiltered.fold<double>(0.0, (sum, expense) => sum + expense.amount);
   
   final amountChange = currentTotal - previousTotal;
   final percentageChange = previousTotal > 0 ? (amountChange / previousTotal) * 100 : 0.0;

   return CategoryComparison(
     categoryId: categoryId,
     currentPeriodTotal: currentTotal,
     previousPeriodTotal: previousTotal,
     currentPeriodCount: currentFiltered.length,
     previousPeriodCount: previousFiltered.length,
     amountChange: amountChange,
     percentageChange: percentageChange,
     isIncrease: amountChange > 0,
   );
 }

 @override
 Future<Map<String, dynamic>> exportStatistics({
   DateTime? startDate,
   DateTime? endDate,
 }) async {
   final stats = await getExpenseStatistics(startDate: startDate, endDate: endDate);
   final categoryData = await getCategorySpendingSummary(startDate: startDate, endDate: endDate);
   final monthlyTrends = await getMonthlySpendingTrend(startDate: startDate, endDate: endDate);
   final insights = await getSpendingInsights(startDate: startDate, endDate: endDate);

   return {
     'exportDate': DateTime.now().toIso8601String(),
     'period': {
       'startDate': startDate?.toIso8601String(),
       'endDate': endDate?.toIso8601String(),
     },
     'summary': {
       'totalAmount': stats.totalAmount,
       'totalExpenses': stats.totalExpenses,
       'averageExpense': stats.averageExpense,
       'daysCovered': stats.daysCovered,
       'dailyAverage': stats.dailyAverage,
     },
     'categoryBreakdown': categoryData.map((cat) => {
       'name': cat.categoryName,
       'total': cat.totalAmount,
       'count': cat.expenseCount,
       'percentage': cat.percentage,
       'average': cat.averageExpense,
     }).toList(),
     'monthlyTrends': monthlyTrends.map((trend) => {
       'month': trend.month.toIso8601String(),
       'total': trend.totalAmount,
       'count': trend.expenseCount,
       'categoryBreakdown': trend.categoryBreakdown,
     }).toList(),
     'insights': insights.map((insight) => {
       'title': insight.title,
       'description': insight.description,
       'type': insight.type.toString(),
       'priority': insight.priority.toString(),
     }).toList(),
   };
 }

 @override
 Future<void> clearStatisticsCache() async {
   _cache.clear();
 }

 @override
 Future<void> refreshStatisticsCache() async {
   _cache.clear();
   // Pre-populate cache with common queries
   await getExpenseStatistics();
   await getCategorySpendingSummary();
   await getMonthlySpendingTrend();
 }

 // Helper methods
 DateTime _getWeekStart(DateTime date) {
   final daysFromMonday = date.weekday - 1;
   return DateTime(date.year, date.month, date.day - daysFromMonday);
 }

 bool _isCacheValid(String cacheKey) {
   final timestamp = _cache['${cacheKey}_timestamp'];
   if (timestamp == null) return false;
   return DateTime.now().difference(timestamp).compareTo(_cacheExpiry) < 0;
 }
}

// Additional entity for category comparison
class CategoryComparison {
 final int categoryId;
 final double currentPeriodTotal;
 final double previousPeriodTotal;
 final int currentPeriodCount;
 final int previousPeriodCount;
 final double amountChange;
 final double percentageChange;
 final bool isIncrease;

 const CategoryComparison({
   required this.categoryId,
   required this.currentPeriodTotal,
   required this.previousPeriodTotal,
   required this.currentPeriodCount,
   required this.previousPeriodCount,
   required this.amountChange,
   required this.percentageChange,
   required this.isIncrease,
 });

 String get formattedCurrentTotal => '\$${currentPeriodTotal.toStringAsFixed(2)}';
 String get formattedPreviousTotal => '\$${previousPeriodTotal.toStringAsFixed(2)}';
 String get formattedChange => '\$${amountChange.abs().toStringAsFixed(2)}';
 String get formattedPercentageChange => '${percentageChange.abs().toStringAsFixed(1)}%';
}
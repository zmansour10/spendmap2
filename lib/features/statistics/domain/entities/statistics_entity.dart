class ExpenseStatistics {
  final double totalAmount;
  final int totalExpenses;
  final double averageExpense;
  final double highestExpense;
  final double lowestExpense;
  final DateTime? startDate;
  final DateTime? endDate;
  final Map<String, double> categoryTotals;
  final Map<String, int> categoryCounts;

  const ExpenseStatistics({
    required this.totalAmount,
    required this.totalExpenses,
    required this.averageExpense,
    required this.highestExpense,
    required this.lowestExpense,
    this.startDate,
    this.endDate,
    required this.categoryTotals,
    required this.categoryCounts,
  });

  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)}';
  String get formattedAverage => '\$${averageExpense.toStringAsFixed(2)}';
  String get formattedHighest => '\$${highestExpense.toStringAsFixed(2)}';
  String get formattedLowest => '\$${lowestExpense.toStringAsFixed(2)}';
  
  int get daysCovered {
    if (startDate == null || endDate == null) return 0;
    return endDate!.difference(startDate!).inDays + 1;
  }
  
  double get dailyAverage => daysCovered > 0 ? totalAmount / daysCovered : 0.0;
  String get formattedDailyAverage => '\$${dailyAverage.toStringAsFixed(2)}';
}

class CategorySpendingSummary {
  final int categoryId;
  final String categoryName;
  final int categoryIconCode;
  final int categoryColorValue;
  final double totalAmount;
  final int expenseCount;
  final double percentage;
  final double averageExpense;

  const CategorySpendingSummary({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIconCode,
    required this.categoryColorValue,
    required this.totalAmount,
    required this.expenseCount,
    required this.percentage,
    required this.averageExpense,
  });

  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)}';
  String get formattedAverage => '\$${averageExpense.toStringAsFixed(3)}';
  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';
}

class MonthlySpendingTrend {
  final DateTime month;
  final double totalAmount;
  final int expenseCount;
  final Map<int, double> categoryBreakdown;

  const MonthlySpendingTrend({
    required this.month,
    required this.totalAmount,
    required this.expenseCount,
    required this.categoryBreakdown,
  });

  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)}';
  String get monthLabel => '${_monthNames[month.month - 1]} ${month.year}';
  
  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
}

class WeeklySpendingTrend {
  final DateTime weekStart;
  final DateTime weekEnd;
  final double totalAmount;
  final int expenseCount;
  final Map<int, double> categoryBreakdown;

  const WeeklySpendingTrend({
    required this.weekStart,
    required this.weekEnd,
    required this.totalAmount,
    required this.expenseCount,
    required this.categoryBreakdown,
  });

  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)}';
  String get weekLabel => '${weekStart.month}/${weekStart.day} - ${weekEnd.month}/${weekEnd.day}';
}

class DailySpendingTrend {
  final DateTime date;
  final double totalAmount;
  final int expenseCount;
  final Map<int, double> categoryBreakdown;

  const DailySpendingTrend({
    required this.date,
    required this.totalAmount,
    required this.expenseCount,
    required this.categoryBreakdown,
  });

  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)}';
  String get dateLabel => '${date.month}/${date.day}';
  String get weekdayLabel => _weekdayNames[date.weekday - 1];
  
  static const _weekdayNames = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
  ];
}

class PeriodComparison {
  final double currentPeriodTotal;
  final double previousPeriodTotal;
  final int currentPeriodCount;
  final int previousPeriodCount;
  final double amountChange;
  final double percentageChange;
  final bool isIncrease;

  const PeriodComparison({
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
  
  String get changeDescription {
    if (amountChange == 0) return 'No change';
    final direction = isIncrease ? 'increased' : 'decreased';
    return '$direction by $formattedChange ($formattedPercentageChange)';
  }
}

class SpendingInsight {
  final String title;
  final String description;
  final InsightType type;
  final InsightPriority priority;
  final Map<String, dynamic> data;

  const SpendingInsight({
    required this.title,
    required this.description,
    required this.type,
    required this.priority,
    required this.data,
  });
}

enum InsightType {
  trendAlert,
  budgetWarning,
  categoryAnomaly,
  spendingPattern,
  savingsOpportunity,
}

enum InsightPriority {
  low,
  medium,
  high,
  critical,
}

enum TrendPeriod {
  daily,
  weekly,
  monthly,
  yearly,
}

// Statistics Filter Enums
enum StatisticsPeriod {
  today,
  thisWeek,
  thisMonth,
  lastMonth,
  thisYear,
  lastYear,
  custom,
}

extension StatisticsPeriodExtension on StatisticsPeriod {
  String get displayName {
    switch (this) {
      case StatisticsPeriod.today:
        return 'Today';
      case StatisticsPeriod.thisWeek:
        return 'This Week';
      case StatisticsPeriod.thisMonth:
        return 'This Month';
      case StatisticsPeriod.lastMonth:
        return 'Last Month';
      case StatisticsPeriod.thisYear:
        return 'This Year';
      case StatisticsPeriod.lastYear:
        return 'Last Year';
      case StatisticsPeriod.custom:
        return 'Custom';
    }
  }

  DateRange get dateRange {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    switch (this) {
      case StatisticsPeriod.today:
        return DateRange(today, today.add(const Duration(days: 1)).subtract(const Duration(seconds: 1)));
      
      case StatisticsPeriod.thisWeek:
        final weekStart = today.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        return DateRange(weekStart, weekEnd);
      
      case StatisticsPeriod.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        final monthEnd = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
        return DateRange(monthStart, monthEnd);
      
      case StatisticsPeriod.lastMonth:
        final lastMonthStart = DateTime(now.year, now.month - 1, 1);
        final lastMonthEnd = DateTime(now.year, now.month, 1).subtract(const Duration(seconds: 1));
        return DateRange(lastMonthStart, lastMonthEnd);
      
      case StatisticsPeriod.thisYear:
        final yearStart = DateTime(now.year, 1, 1);
        final yearEnd = DateTime(now.year, 12, 31, 23, 59, 59);
        return DateRange(yearStart, yearEnd);
      
      case StatisticsPeriod.lastYear:
        final lastYearStart = DateTime(now.year - 1, 1, 1);
        final lastYearEnd = DateTime(now.year - 1, 12, 31, 23, 59, 59);
        return DateRange(lastYearStart, lastYearEnd);
      
      case StatisticsPeriod.custom:
        return DateRange(today, today);
    }
  }
}

enum ChartType {
  pie,
  line,
  bar,
}

extension ChartTypeExtension on ChartType {
  String get displayName {
    switch (this) {
      case ChartType.pie:
        return 'Pie Chart';
      case ChartType.line:
        return 'Line Chart';
      case ChartType.bar:
        return 'Bar Chart';
    }
  }
}

// Anomaly Detection
enum AnomalyType {
  unusuallyHigh,
  unusuallyLow,
  unexpectedCategory,
  frequencyAnomaly,
}

class AnomalyDetection {
  final AnomalyType type;
  final DateTime date;
  final double actualValue;
  final double expectedValue;
  final String description;
  final double severity; // 0.0 to 1.0

  const AnomalyDetection({
    required this.type,
    required this.date,
    required this.actualValue,
    required this.expectedValue,
    required this.description,
    required this.severity,
  });

  String get formattedActual => '\$${actualValue.toStringAsFixed(2)}';
  String get formattedExpected => '\$${expectedValue.toStringAsFixed(2)}';
}

// Category Insights
class CategoryInsight {
  final int categoryId;
  final String categoryName;
  final String insight;
  final InsightType type;
  final InsightPriority priority;
  final Map<String, dynamic> data;

  const CategoryInsight({
    required this.categoryId,
    required this.categoryName,
    required this.insight,
    required this.type,
    required this.priority,
    required this.data,
  });
}

// Date Range Helper
class DateRange {
  final DateTime start;
  final DateTime end;

  const DateRange(this.start, this.end);

  Duration get duration => end.difference(start);
  int get days => duration.inDays + 1;

  bool contains(DateTime date) {
    return date.isAfter(start.subtract(const Duration(seconds: 1))) && 
           date.isBefore(end.add(const Duration(seconds: 1)));
  }
}

// Statistics Filter State
class StatisticsFilterState {
  final StatisticsPeriod period;
  final ChartType chartType;
  final DateTime startDate;
  final DateTime endDate;
  final List<int>? categoryIds;

  const StatisticsFilterState({
    required this.period,
    required this.chartType,
    required this.startDate,
    required this.endDate,
    this.categoryIds,
  });

  factory StatisticsFilterState.thisMonth() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
    
    return StatisticsFilterState(
      period: StatisticsPeriod.thisMonth,
      chartType: ChartType.pie,
      startDate: monthStart,
      endDate: monthEnd,
    );
  }

  StatisticsFilterState copyWith({
    StatisticsPeriod? period,
    ChartType? chartType,
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
  }) {
    return StatisticsFilterState(
      period: period ?? this.period,
      chartType: chartType ?? this.chartType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryIds: categoryIds ?? this.categoryIds,
    );
  }

  bool get hasActiveCategoryFilter => categoryIds != null && categoryIds!.isNotEmpty;
}
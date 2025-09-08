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
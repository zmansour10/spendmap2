import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:spendmap2/features/statistics/domain/entities/statistics_entity.dart';

class BudgetStatus {
  final int categoryId;
  final String categoryName;
  final double budgetAmount;
  final double spentAmount;
  final double remainingAmount;
  final double percentageUsed;
  final BudgetHealthStatus healthStatus;
  final DateTime periodStart;
  final DateTime periodEnd;

  const BudgetStatus({
    required this.categoryId,
    required this.categoryName,
    required this.budgetAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.percentageUsed,
    required this.healthStatus,
    required this.periodStart,
    required this.periodEnd,
  });

  String get formattedBudget => '\$${budgetAmount.toStringAsFixed(2)}';
  String get formattedSpent => '\$${spentAmount.toStringAsFixed(2)}';
  String get formattedRemaining => '\$${remainingAmount.toStringAsFixed(2)}';
  String get formattedPercentage => '${percentageUsed.toStringAsFixed(1)}%';
  
  bool get isOverBudget => spentAmount > budgetAmount;
  bool get isNearBudget => percentageUsed >= 80 && percentageUsed < 100;
  
  String get statusMessage {
    if (isOverBudget) {
      final overAmount = spentAmount - budgetAmount;
      return 'Over budget by \$${overAmount.toStringAsFixed(2)}';
    } else if (isNearBudget) {
      return 'Approaching budget limit';
    } else {
      return 'Within budget';
    }
  }
}

class BudgetOverview {
  final double totalBudget;
  final double totalSpent;
  final double totalRemaining;
  final double overallPercentageUsed;
  final int categoriesOverBudget;
  final int categoriesNearBudget;
  final int totalCategories;
  final DateTime? periodStart;
  final DateTime? periodEnd;
  final List<BudgetStatus> categoryStatuses;

  const BudgetOverview({
    required this.totalBudget,
    required this.totalSpent,
    required this.totalRemaining,
    required this.overallPercentageUsed,
    required this.categoriesOverBudget,
    required this.categoriesNearBudget,
    required this.totalCategories,
    required this.periodStart,
    required this.periodEnd,
    required this.categoryStatuses,
  });

  String get formattedTotalBudget => '\$${totalBudget.toStringAsFixed(2)}';
  String get formattedTotalSpent => '\$${totalSpent.toStringAsFixed(2)}';
  String get formattedTotalRemaining => '\$${totalRemaining.toStringAsFixed(2)}';
  String get formattedOverallPercentage => '${overallPercentageUsed.toStringAsFixed(1)}%';
  
  BudgetHealthStatus get overallHealthStatus {
    if (categoriesOverBudget > 0) return BudgetHealthStatus.critical;
    if (categoriesNearBudget > 0) return BudgetHealthStatus.warning;
    if (overallPercentageUsed >= 80) return BudgetHealthStatus.caution;
    return BudgetHealthStatus.healthy;
  }
  
  String get healthSummary {
    if (categoriesOverBudget > 0) {
      return '$categoriesOverBudget categories over budget';
    } else if (categoriesNearBudget > 0) {
      return '$categoriesNearBudget categories near budget limit';
    } else {
      return 'All categories within budget';
    }
  }
}

enum BudgetHealthStatus {
  healthy,
  caution,
  warning,
  critical,
}

extension BudgetHealthStatusExtension on BudgetHealthStatus {
  String get displayName {
    switch (this) {
      case BudgetHealthStatus.healthy:
        return 'Healthy';
      case BudgetHealthStatus.caution:
        return 'Caution';
      case BudgetHealthStatus.warning:
        return 'Warning';
      case BudgetHealthStatus.critical:
        return 'Critical';
    }
  }
  
  Color get color {
    switch (this) {
      case BudgetHealthStatus.healthy:
        return Colors.green;
      case BudgetHealthStatus.caution:
        return Colors.yellow;
      case BudgetHealthStatus.warning:
        return Colors.orange;
      case BudgetHealthStatus.critical:
        return Colors.red;
    }
  }
}

// CategoryInsight and AnomalyDetection moved to statistics_entity.dart to avoid duplication
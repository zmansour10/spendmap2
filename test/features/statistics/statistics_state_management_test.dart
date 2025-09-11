import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendmap2/features/statistics/domain/entities/budget_entity.dart';
import 'package:spendmap2/features/statistics/domain/entities/statistics_entity.dart';
import 'package:spendmap2/features/statistics/domain/entities/chart_data_entity.dart';
import 'package:spendmap2/features/statistics/presentation/providers/statistics_provider.dart';

void main() {
  group('Statistics State Management Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Statistics Filter Provider', () {
      test('should initialize with this month as default', () {
        final filterState = container.read(statisticsFilterProvider);
        
        expect(filterState.period, equals(StatisticsPeriod.thisMonth));
        expect(filterState.chartType, equals(ChartType.pie));
        expect(filterState.categoryIds, isNull);
        
        // Check if dates are set to this month
        final now = DateTime.now();
        expect(filterState.startDate.year, equals(now.year));
        expect(filterState.startDate.month, equals(now.month));
        expect(filterState.startDate.day, equals(1));
      });

      test('should update date range correctly', () {
        final filterNotifier = container.read(statisticsFilterProvider.notifier);
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);
        
        filterNotifier.setDateRange(startDate, endDate);
        
        final filterState = container.read(statisticsFilterProvider);
        expect(filterState.startDate, equals(startDate));
        expect(filterState.endDate, equals(endDate));
        expect(filterState.period, equals(StatisticsPeriod.custom));
      });

      test('should set period correctly', () {
        final filterNotifier = container.read(statisticsFilterProvider.notifier);
        
        filterNotifier.setPeriod(StatisticsPeriod.thisWeek);
        
        final filterState = container.read(statisticsFilterProvider);
        expect(filterState.period, equals(StatisticsPeriod.thisWeek));
        
        // Check if dates are set to this week
        final now = DateTime.now();
        final expectedStart = _getWeekStart(now);
        expect(filterState.startDate.day, equals(expectedStart.day));
      });

      test('should handle category filter updates', () {
        final filterNotifier = container.read(statisticsFilterProvider.notifier);
        
        filterNotifier.setCategoryFilter([1, 2, 3]);
        
        final filterState = container.read(statisticsFilterProvider);
        expect(filterState.categoryIds, equals([1, 2, 3]));
        expect(filterState.hasActiveCategoryFilter, isTrue);
        
        // Clear category filter
        filterNotifier.setCategoryFilter([]);
        final clearedState = container.read(statisticsFilterProvider);
        expect(clearedState.hasActiveCategoryFilter, isFalse);
      });

      test('should update chart type correctly', () {
        final filterNotifier = container.read(statisticsFilterProvider.notifier);
        
        filterNotifier.setChartType(ChartType.bar);
        
        final filterState = container.read(statisticsFilterProvider);
        expect(filterState.chartType, equals(ChartType.bar));
      });

      test('should have valid date range', () {
        final filterState = container.read(statisticsFilterProvider);
        
        expect(filterState.startDate.isBefore(filterState.endDate), isTrue);
        expect(filterState.endDate.difference(filterState.startDate).inDays, greaterThan(0));
      });

      test('should generate correct display names', () {
        final filterNotifier = container.read(statisticsFilterProvider.notifier);
        
        filterNotifier.setPeriod(StatisticsPeriod.today);
        expect(container.read(statisticsFilterProvider).period.displayName, equals('Today'));
        
        filterNotifier.setPeriod(StatisticsPeriod.thisWeek);
        expect(container.read(statisticsFilterProvider).period.displayName, equals('This Week'));
        
        filterNotifier.setPeriod(StatisticsPeriod.thisMonth);
        expect(container.read(statisticsFilterProvider).period.displayName, equals('This Month'));
      });

      test('should handle custom date range correctly', () {
        final filterNotifier = container.read(statisticsFilterProvider.notifier);
        final startDate = DateTime(2024, 1, 15);
        final endDate = DateTime(2024, 2, 14);
        
        filterNotifier.setDateRange(startDate, endDate);
        
        final filterState = container.read(statisticsFilterProvider);
        
        expect(filterState.startDate, equals(startDate));
        expect(filterState.endDate, equals(endDate));
        expect(filterState.period, equals(StatisticsPeriod.custom));
      });
    });

    group('Dashboard Stats Model', () {
      test('should calculate averages correctly', () {
        final dashboardStats = DashboardStats(
          todayTotal: 50.0,
          todayCount: 2,
          weekTotal: 350.0,
          weekCount: 14,
          monthTotal: 1200.0,
          monthCount: 48,
          topCategories: [],
          lastUpdated: DateTime.now(),
        );

        expect(dashboardStats.weekDailyAverage, equals(50.0)); // 350 / 7
        expect(dashboardStats.formattedTodayTotal, equals('\$50.00'));
        expect(dashboardStats.formattedWeekTotal, equals('\$350.00'));
        expect(dashboardStats.formattedMonthTotal, equals('\$1200.00'));
      });

      test('should format amounts correctly', () {
        final dashboardStats = DashboardStats(
          todayTotal: 123.456,
          todayCount: 1,
          weekTotal: 1234.567,
          weekCount: 7,
          monthTotal: 12345.678,
          monthCount: 30,
          topCategories: [],
          lastUpdated: DateTime.now(),
        );

        expect(dashboardStats.formattedTodayTotal, equals('\$123.46'));
        expect(dashboardStats.formattedWeekTotal, equals('\$1234.57'));
        expect(dashboardStats.formattedMonthTotal, equals('\$12345.68'));
      });
    });

    group('Chart Type Extensions', () {
      test('should have correct display names', () {
        expect(ChartType.pie.displayName, equals('Pie Chart'));
        expect(ChartType.bar.displayName, equals('Bar Chart'));
        expect(ChartType.line.displayName, equals('Line Chart'));
      });
    });

    group('Statistics Export Result', () {
      test('should create success result correctly', () {
        final data = {'test': 'value'};
        final result = StatisticsExportResult.success('Export completed', data: data);
        
        expect(result.isSuccess, isTrue);
        expect(result.message, equals('Export completed'));
        expect(result.data, equals(data));
      });

      test('should create error result correctly', () {
        final result = StatisticsExportResult.error('Export failed');
        
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('Export failed'));
        expect(result.data, isNull);
      });
    });

    group('Statistics Cache Result', () {
      test('should create success result correctly', () {
        final result = StatisticsCacheResult.success('Cache cleared');
        
        expect(result.isSuccess, isTrue);
        expect(result.message, equals('Cache cleared'));
      });

      test('should create error result correctly', () {
        final result = StatisticsCacheResult.error('Cache error');
        
        expect(result.isSuccess, isFalse);
        expect(result.message, equals('Cache error'));
      });
    });

    group('Statistics Filter State', () {
      test('should create this month filter correctly', () {
        final filterState = StatisticsFilterState.thisMonth();
        final now = DateTime.now();
        
        expect(filterState.period, equals(StatisticsPeriod.thisMonth));
        expect(filterState.startDate.year, equals(now.year));
        expect(filterState.startDate.month, equals(now.month));
        expect(filterState.startDate.day, equals(1));
        expect(filterState.chartType, equals(ChartType.pie));
      });

      test('should copy with new values correctly', () {
        final originalState = StatisticsFilterState.thisMonth();
        final newStartDate = DateTime(2023, 6, 1);
        
        final copiedState = originalState.copyWith(
          startDate: newStartDate,
          period: StatisticsPeriod.custom,
        );
        
        expect(copiedState.startDate, equals(newStartDate));
        expect(copiedState.period, equals(StatisticsPeriod.custom));
        expect(copiedState.endDate, equals(originalState.endDate));
        expect(copiedState.chartType, equals(originalState.chartType));
      });

      test('should detect active category filter correctly', () {
        final stateWithoutFilter = StatisticsFilterState.thisMonth();
        expect(stateWithoutFilter.hasActiveCategoryFilter, isFalse);
        
        final stateWithEmptyFilter = stateWithoutFilter.copyWith(categoryIds: []);
        expect(stateWithEmptyFilter.hasActiveCategoryFilter, isFalse);
        
        final stateWithFilter = stateWithoutFilter.copyWith(categoryIds: [1, 2]);
        expect(stateWithFilter.hasActiveCategoryFilter, isTrue);
      });
    });

    group('Statistics Entities', () {
      group('ExpenseStatistics', () {
        test('should calculate daily average correctly', () {
          final stats = ExpenseStatistics(
            totalAmount: 300.0,
            totalExpenses: 10,
            averageExpense: 30.0,
            highestExpense: 100.0,
            lowestExpense: 5.0,
            startDate: DateTime(2024, 1, 1),
            endDate: DateTime(2024, 1, 10), // 10 days
            categoryTotals: {},
            categoryCounts: {},
          );

          expect(stats.daysCovered, equals(10));
          expect(stats.dailyAverage, equals(30.0)); // 300 / 10
          expect(stats.formattedDailyAverage, equals('\$30.00'));
        });

        test('should format amounts correctly', () {
          final stats = ExpenseStatistics(
            totalAmount: 1234.567,
            totalExpenses: 5,
            averageExpense: 246.9134,
            highestExpense: 500.12,
            lowestExpense: 12.34,
            categoryTotals: {},
            categoryCounts: {},
          );

          expect(stats.formattedTotal, equals('\$1234.57'));
          expect(stats.formattedAverage, equals('\$246.91'));
          expect(stats.formattedHighest, equals('\$500.12'));
          expect(stats.formattedLowest, equals('\$12.34'));
        });
      });

      group('CategorySpendingSummary', () {
        test('should format values correctly', () {
          final summary = CategorySpendingSummary(
            categoryId: 1,
            categoryName: 'Food',
            categoryIconCode: 123,
            categoryColorValue: 0xFF000000,
            totalAmount: 456.789,
            expenseCount: 12,
            percentage: 35.67,
            averageExpense: 38.065,
          );

          expect(summary.formattedTotal, equals('\$456.79'));
          expect(summary.formattedAverage, equals('\$38.065'));
          expect(summary.formattedPercentage, equals('35.7%'));
        });
      });

      group('MonthlySpendingTrend', () {
        test('should generate correct month label', () {
          final trend = MonthlySpendingTrend(
            month: DateTime(2024, 3, 1),
            totalAmount: 500.0,
            expenseCount: 15,
            categoryBreakdown: {},
          );

          expect(trend.monthLabel, equals('Mar 2024'));
          expect(trend.formattedTotal, equals('\$500.00'));
        });
      });

      group('PeriodComparison', () {
        test('should calculate changes correctly', () {
          final comparison = PeriodComparison(
            currentPeriodTotal: 400.0,
            previousPeriodTotal: 300.0,
            currentPeriodCount: 8,
            previousPeriodCount: 6,
            amountChange: 100.0,
            percentageChange: 33.33,
            isIncrease: true,
          );

          expect(comparison.formattedChange, equals('\$100.00'));
          expect(comparison.formattedPercentageChange, equals('33.3%'));
          expect(comparison.changeDescription, contains('increased'));
          expect(comparison.changeDescription, contains('\$100.00'));
          expect(comparison.changeDescription, contains('33.3%'));
        });

        test('should handle decrease correctly', () {
          final comparison = PeriodComparison(
            currentPeriodTotal: 200.0,
            previousPeriodTotal: 300.0,
            currentPeriodCount: 4,
            previousPeriodCount: 6,
            amountChange: -100.0,
            percentageChange: -33.33,
            isIncrease: false,
          );

          expect(comparison.isIncrease, isFalse);
          expect(comparison.changeDescription, contains('decreased'));
          expect(comparison.formattedChange, equals('\$100.00')); // Absolute value
        });

        test('should handle no change correctly', () {
          final comparison = PeriodComparison(
            currentPeriodTotal: 300.0,
            previousPeriodTotal: 300.0,
            currentPeriodCount: 6,
            previousPeriodCount: 6,
            amountChange: 0.0,
            percentageChange: 0.0,
            isIncrease: false,
          );

          expect(comparison.changeDescription, equals('No change'));
        });
      });
    });

    group('Chart Data Entities', () {
      group('PieChartData', () {
        test('should calculate percentage correctly', () {
          final pieData = PieChartData(
            label: 'Food',
            value: 150.0,
            color: const Color(0xFF000000),
          );

          expect(pieData.calculatePercentage(500.0), equals(30.0));
          expect(pieData.formattedPercentage(500.0), equals('30.0%'));
          expect(pieData.formattedValue, equals('\$150.00'));
        });

        test('should handle zero total correctly', () {
          final pieData = PieChartData(
            label: 'Food',
            value: 150.0,
            color: const Color(0xFF000000),
          );

          expect(pieData.calculatePercentage(0.0), equals(0.0));
          expect(pieData.formattedPercentage(0.0), equals('0.0%'));
        });
      });

      group('ChartDataSet', () {
        test('should provide correct properties', () {
          final dataSet = ChartDataSet<PieChartData>(
            title: 'Category Spending',
            data: [
              PieChartData(label: 'Food', value: 100, color: const Color(0xFF000000)),
              PieChartData(label: 'Transport', value: 50, color: const Color(0xFF111111)),
            ],
            primaryColor: const Color(0xFF000000),
          );

          expect(dataSet.isEmpty, isFalse);
          expect(dataSet.isNotEmpty, isTrue);
          expect(dataSet.length, equals(2));
          expect(dataSet.title, equals('Category Spending'));
        });
      });
    });

    group('Budget Entities', () {
      group('BudgetStatus', () {
        test('should calculate status correctly', () {
          final budgetStatus = BudgetStatus(
            categoryId: 1,
            categoryName: 'Food',
            budgetAmount: 500.0,
            spentAmount: 450.0,
            remainingAmount: 50.0,
            percentageUsed: 90.0,
            healthStatus: BudgetHealthStatus.warning,
            periodStart: DateTime(2024, 1, 1),
            periodEnd: DateTime(2024, 1, 31),
          );

          expect(budgetStatus.isOverBudget, isFalse);
          expect(budgetStatus.isNearBudget, isTrue); // >= 80% and < 100%
          expect(budgetStatus.statusMessage, equals('Approaching budget limit'));
          expect(budgetStatus.formattedBudget, equals('\$500.00'));
          expect(budgetStatus.formattedSpent, equals('\$450.00'));
          expect(budgetStatus.formattedPercentage, equals('90.0%'));
        });

        test('should handle over budget correctly', () {
          final budgetStatus = BudgetStatus(
            categoryId: 1,
            categoryName: 'Food',
            budgetAmount: 500.0,
            spentAmount: 550.0,
            remainingAmount: -50.0,
            percentageUsed: 110.0,
            healthStatus: BudgetHealthStatus.critical,
            periodStart: DateTime(2024, 1, 1),
            periodEnd: DateTime(2024, 1, 31),
          );

          expect(budgetStatus.isOverBudget, isTrue);
          expect(budgetStatus.isNearBudget, isFalse);
          expect(budgetStatus.statusMessage, equals('Over budget by \$50.00'));
        });
      });
    });
  });
}

// Helper function for tests
DateTime _getWeekStart(DateTime date) {
  final daysFromMonday = date.weekday - 1;
  return DateTime(date.year, date.month, date.day - daysFromMonday);
}
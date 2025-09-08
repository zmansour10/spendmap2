import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spendmap2/features/expenses/data/models/expense.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../categories/domain/entities/category_entity.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import 'expense_provider.dart';

part 'expense_filter_provider.g.dart';

// Expense Filter State Provider (renamed to avoid conflict)
@riverpod
class ExpenseFilterController extends _$ExpenseFilterController {
  @override
  ExpenseFilterViewState build() {
    return const ExpenseFilterViewState.initial();
  }

  /// Set date range filter
  void setDateRange(DateTime? startDate, DateTime? endDate) {
    state = state.copyWith(startDate: startDate, endDate: endDate);
  }

  /// Set amount range filter
  void setAmountRange(double? minAmount, double? maxAmount) {
    state = state.copyWith(minAmount: minAmount, maxAmount: maxAmount);
  }

  /// Set category filter
  void setCategoryFilter(List<int>? categoryIds) {
    state = state.copyWith(categoryIds: categoryIds);
  }

  /// Add category to filter
  void addCategoryToFilter(int categoryId) {
    final currentCategories = state.categoryIds ?? [];
    if (!currentCategories.contains(categoryId)) {
      state = state.copyWith(categoryIds: [...currentCategories, categoryId]);
    }
  }

  /// Remove category from filter
  void removeCategoryFromFilter(int categoryId) {
    final currentCategories = state.categoryIds ?? [];
    state = state.copyWith(
      categoryIds: currentCategories.where((id) => id != categoryId).toList(),
    );
  }

  /// Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  /// Set sort option
  void setSortOption(ExpenseSortOption sortOption) {
    state = state.copyWith(sortOption: sortOption);
  }

  /// Toggle sort direction
  void toggleSortDirection() {
    state = state.copyWith(sortAscending: !state.sortAscending);
  }

  /// Set time period filter
  void setTimePeriod(ExpenseTimePeriod timePeriod) {
    final now = DateTime.now();
    DateTime? startDate;
    DateTime? endDate;

    switch (timePeriod) {
      case ExpenseTimePeriod.today:
        startDate = DateTime(now.year, now.month, now.day);
        endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case ExpenseTimePeriod.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
        endDate = DateTime(
          yesterday.year,
          yesterday.month,
          yesterday.day,
          23,
          59,
          59,
        );
        break;
      case ExpenseTimePeriod.thisWeek:
        final daysFromMonday = now.weekday - 1;
        startDate = DateTime(now.year, now.month, now.day - daysFromMonday);
        endDate = now;
        break;
      case ExpenseTimePeriod.lastWeek:
        final daysFromLastMonday = now.weekday + 6;
        final lastWeekEnd = now.subtract(Duration(days: now.weekday));
        startDate = DateTime(now.year, now.month, now.day - daysFromLastMonday);
        endDate = lastWeekEnd;
        break;
      case ExpenseTimePeriod.thisMonth:
        startDate = DateTime(now.year, now.month, 1);
        endDate = now;
        break;
      case ExpenseTimePeriod.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, 1);
        startDate = lastMonth;
        endDate = DateTime(
          now.year,
          now.month,
          1,
        ).subtract(const Duration(days: 1));
        break;
      case ExpenseTimePeriod.thisYear:
        startDate = DateTime(now.year, 1, 1);
        endDate = now;
        break;
      case ExpenseTimePeriod.lastYear:
        startDate = DateTime(now.year - 1, 1, 1);
        endDate = DateTime(now.year - 1, 12, 31, 23, 59, 59);
        break;
      case ExpenseTimePeriod.all:
        startDate = null;
        endDate = null;
        break;
      case ExpenseTimePeriod.custom:
        // Keep existing dates for custom range
        return;
    }

    state = state.copyWith(
      timePeriod: timePeriod,
      startDate: startDate,
      endDate: endDate,
    );
  }

  /// Clear all filters
  void clearAllFilters() {
    state = const ExpenseFilterViewState.initial();
  }

  /// Clear specific filter
  /// Clear specific filter
void clearDateFilter() {
  state = state.copyWith(
    clearStartDate: true,
    clearEndDate: true,
    timePeriod: ExpenseTimePeriod.all,
  );
}

void clearAmountFilter() {
  state = state.copyWith(
    clearMinAmount: true,
    clearMaxAmount: true,
  );
}

void clearCategoryFilter() {
  state = state.copyWith(
    clearCategoryIds: true,
  );
}

  void clearSearchQuery() {
    state = state.copyWith(searchQuery: '');
  }

  /// Apply preset filters
  void applyPresetFilter(ExpenseFilterPreset preset) {
    switch (preset) {
      case ExpenseFilterPreset.recentHighAmount:
        state = state.copyWith(
          timePeriod: ExpenseTimePeriod.thisMonth,
          minAmount: 100.0,
          sortOption: ExpenseSortOption.amountHighest,
        );
        setTimePeriod(ExpenseTimePeriod.thisMonth);
        break;
      case ExpenseFilterPreset.todayExpenses:
        setTimePeriod(ExpenseTimePeriod.today);
        break;
      case ExpenseFilterPreset.thisWeekExpenses:
        setTimePeriod(ExpenseTimePeriod.thisWeek);
        break;
      case ExpenseFilterPreset.largeExpenses:
        state = state.copyWith(
          minAmount: 200.0,
          sortOption: ExpenseSortOption.amountHighest,
          timePeriod: ExpenseTimePeriod.all,
        );
        break;
      case ExpenseFilterPreset.recentExpenses:
        state = state.copyWith(
          sortOption: ExpenseSortOption.dateNewest,
          timePeriod: ExpenseTimePeriod.all,
        );
        break;
    }
  }
}

// Filtered Expenses Provider
@riverpod
Future<List<ExpenseEntity>> filteredExpenses(FilteredExpensesRef ref) async {
  final filterState = ref.watch(expenseFilterControllerProvider);
  final repository = ref.watch(expenseRepositoryProvider);

  // Convert filter view state to domain ExpenseFilter entity
  final expenseFilter = ExpenseFilter(
    startDate: filterState.startDate,
    endDate: filterState.endDate,
    categoryIds: filterState.categoryIds,
    minAmount: filterState.minAmount,
    maxAmount: filterState.maxAmount,
    searchQuery: filterState.searchQuery,
    sortOption: filterState.sortOption,
    sortAscending: filterState.sortAscending,
  );

  return await repository.getFilteredExpenses(expenseFilter);
}

// Filtered Expenses with Categories Provider
@riverpod
Future<List<ExpenseWithCategory>> filteredExpensesWithCategories(
  FilteredExpensesWithCategoriesRef ref,
) async {
  final filterState = ref.watch(expenseFilterControllerProvider);
  final repository = ref.watch(expenseRepositoryProvider);

  // Convert filter view state to domain ExpenseFilter entity
  final expenseFilter = ExpenseFilter(
    startDate: filterState.startDate,
    endDate: filterState.endDate,
    categoryIds: filterState.categoryIds,
    minAmount: filterState.minAmount,
    maxAmount: filterState.maxAmount,
    searchQuery: filterState.searchQuery,
    sortOption: filterState.sortOption,
    sortAscending: filterState.sortAscending,
  );

  return await repository.getExpensesWithCategories(filter: expenseFilter);
}

// Filter Statistics Provider
@riverpod
Future<ExpenseFilterStats> filterStatistics(FilterStatisticsRef ref) async {
  final filterState = ref.watch(expenseFilterControllerProvider);
  final repository = ref.watch(expenseRepositoryProvider);

  // Get total count without filters
  final allExpenses = await repository.getAllExpenses();
  final totalCount = allExpenses.length;

  // Get filtered results
  final filteredExpenses = await ref.watch(filteredExpensesProvider.future);
  final filteredCount = filteredExpenses.length;

  // Calculate filtered total and average
  final filteredTotal = filteredExpenses.fold<double>(
    0.0,
    (sum, expense) => sum + expense.amount,
  );
  final filteredAverage = filteredCount > 0
      ? filteredTotal / filteredCount
      : 0.0;

  return ExpenseFilterStats(
    totalExpenses: totalCount,
    filteredCount: filteredCount,
    filteredTotal: filteredTotal,
    filteredAverage: filteredAverage,
    filterEfficiency: totalCount > 0 ? (filteredCount / totalCount) * 100 : 0.0,
  );
}

// Category Filter Options Provider
@riverpod
Future<List<CategoryFilterOption>> categoryFilterOptions(
  CategoryFilterOptionsRef ref,
) async {
  final categories = await ref.watch(activeCategoriesProvider.future);
  final repository = ref.watch(expenseRepositoryProvider);

  final options = <CategoryFilterOption>[];

  for (final category in categories) {
    final expenseCount = await repository.getExpenseCount(
      categoryIds: [category.id!],
    );
    final totalAmount = await repository.getTotalExpenses(
      categoryIds: [category.id!],
    );

    options.add(
      CategoryFilterOption(
        category: category,
        expenseCount: expenseCount,
        totalAmount: totalAmount,
      ),
    );
  }

  // Sort by expense count (most used first)
  options.sort((a, b) => b.expenseCount.compareTo(a.expenseCount));

  return options;
}

/// Expense filter view state (renamed from ExpenseFilterState)
class ExpenseFilterViewState {
  final DateTime? startDate;
  final DateTime? endDate;
  final double? minAmount;
  final double? maxAmount;
  final List<int>? categoryIds;
  final String searchQuery;
  final ExpenseSortOption sortOption;
  final bool sortAscending;
  final ExpenseTimePeriod timePeriod;

  const ExpenseFilterViewState({
    this.startDate,
    this.endDate,
    this.minAmount,
    this.maxAmount,
    this.categoryIds,
    required this.searchQuery,
    required this.sortOption,
    required this.sortAscending,
    required this.timePeriod,
  });

  const ExpenseFilterViewState.initial()
    : startDate = null,
      endDate = null,
      minAmount = null,
      maxAmount = null,
      categoryIds = null,
      searchQuery = '',
      sortOption = ExpenseSortOption.dateNewest,
      sortAscending = false,
      timePeriod = ExpenseTimePeriod.all;

  ExpenseFilterViewState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    double? minAmount,
    double? maxAmount,
    List<int>? categoryIds,
    String? searchQuery,
    ExpenseSortOption? sortOption,
    bool? sortAscending,
    ExpenseTimePeriod? timePeriod,
    // Add these to handle explicit nulls
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
    bool clearCategoryIds = false,
  }) {
    return ExpenseFilterViewState(
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
      categoryIds: clearCategoryIds ? null : (categoryIds ?? this.categoryIds),
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      sortAscending: sortAscending ?? this.sortAscending,
      timePeriod: timePeriod ?? this.timePeriod,
    );
  }

  /// Check if any filters are active
  bool get hasActiveFilters {
    return startDate != null ||
        endDate != null ||
        minAmount != null ||
        maxAmount != null ||
        (categoryIds != null && categoryIds!.isNotEmpty) ||
        searchQuery.isNotEmpty;
  }

  /// Get active filter count
  int get activeFilterCount {
    int count = 0;
    if (startDate != null || endDate != null) count++;
    if (minAmount != null || maxAmount != null) count++;
    if (categoryIds != null && categoryIds!.isNotEmpty) count++;
    if (searchQuery.isNotEmpty) count++;
    return count;
  }

  /// Get filter summary
  String get filterSummary {
    if (!hasActiveFilters) return 'No filters applied';

    final parts = <String>[];

    if (timePeriod != ExpenseTimePeriod.all) {
      parts.add(timePeriod.displayName);
    }

    if (categoryIds != null && categoryIds!.isNotEmpty) {
      parts.add('${categoryIds!.length} categories');
    }

    if (minAmount != null && maxAmount != null) {
      parts.add(
        '\$${minAmount!.toStringAsFixed(0)}-\$${maxAmount!.toStringAsFixed(0)}',
      );
    } else if (minAmount != null) {
      parts.add('Min \$${minAmount!.toStringAsFixed(0)}');
    } else if (maxAmount != null) {
      parts.add('Max \$${maxAmount!.toStringAsFixed(0)}');
    }

    if (searchQuery.isNotEmpty) {
      parts.add('"$searchQuery"');
    }

    return parts.join(', ');
  }

  @override
  String toString() {
    return 'ExpenseFilterViewState(timePeriod: $timePeriod, categories: ${categoryIds?.length}, search: "$searchQuery", sort: $sortOption)';
  }
}

// Keep all the rest of the enums and classes the same...
/// Time period options
enum ExpenseTimePeriod {
  all,
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisYear,
  lastYear,
  custom,
}

extension ExpenseTimePeriodExtension on ExpenseTimePeriod {
  String get displayName {
    switch (this) {
      case ExpenseTimePeriod.all:
        return 'All Time';
      case ExpenseTimePeriod.today:
        return 'Today';
      case ExpenseTimePeriod.yesterday:
        return 'Yesterday';
      case ExpenseTimePeriod.thisWeek:
        return 'This Week';
      case ExpenseTimePeriod.lastWeek:
        return 'Last Week';
      case ExpenseTimePeriod.thisMonth:
        return 'This Month';
      case ExpenseTimePeriod.lastMonth:
        return 'Last Month';
      case ExpenseTimePeriod.thisYear:
        return 'This Year';
      case ExpenseTimePeriod.lastYear:
        return 'Last Year';
      case ExpenseTimePeriod.custom:
        return 'Custom Range';
    }
  }
}

/// Filter preset options
enum ExpenseFilterPreset {
  recentHighAmount,
  todayExpenses,
  thisWeekExpenses,
  largeExpenses,
  recentExpenses,
}

extension ExpenseFilterPresetExtension on ExpenseFilterPreset {
  String get displayName {
    switch (this) {
      case ExpenseFilterPreset.recentHighAmount:
        return 'Recent High Amounts';
      case ExpenseFilterPreset.todayExpenses:
        return 'Today\'s Expenses';
      case ExpenseFilterPreset.thisWeekExpenses:
        return 'This Week\'s Expenses';
      case ExpenseFilterPreset.largeExpenses:
        return 'Large Expenses';
      case ExpenseFilterPreset.recentExpenses:
        return 'Recent Expenses';
    }
  }

  String get description {
    switch (this) {
      case ExpenseFilterPreset.recentHighAmount:
        return 'Expenses over \$100 this month';
      case ExpenseFilterPreset.todayExpenses:
        return 'All expenses from today';
      case ExpenseFilterPreset.thisWeekExpenses:
        return 'All expenses from this week';
      case ExpenseFilterPreset.largeExpenses:
        return 'Expenses over \$200';
      case ExpenseFilterPreset.recentExpenses:
        return 'Most recent expenses first';
    }
  }
}

/// Filter statistics
class ExpenseFilterStats {
  final int totalExpenses;
  final int filteredCount;
  final double filteredTotal;
  final double filteredAverage;
  final double filterEfficiency;

  const ExpenseFilterStats({
    required this.totalExpenses,
    required this.filteredCount,
    required this.filteredTotal,
    required this.filteredAverage,
    required this.filterEfficiency,
  });

  String get formattedTotal => '\$${filteredTotal.toStringAsFixed(2)}';
  String get formattedAverage => '\$${filteredAverage.toStringAsFixed(2)}';
  String get efficiencyPercentage => '${filterEfficiency.toStringAsFixed(1)}%';

  String get resultSummary {
    if (filteredCount == totalExpenses) {
      return 'Showing all $totalExpenses expenses';
    }
    return 'Showing $filteredCount of $totalExpenses expenses';
  }
}

/// Category filter option
class CategoryFilterOption {
  final CategoryEntity category;
  final int expenseCount;
  final double totalAmount;

  const CategoryFilterOption({
    required this.category,
    required this.expenseCount,
    required this.totalAmount,
  });

  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)}';
  String get displayText => '${category.name} ($expenseCount expenses)';
}

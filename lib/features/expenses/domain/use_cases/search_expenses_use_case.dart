import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

/// Use case for searching expenses with advanced search capabilities
class SearchExpensesUseCase {
  final ExpenseRepository _repository;

  const SearchExpensesUseCase(this._repository);

  /// Execute the use case
  Future<SearchExpensesResult> execute(SearchExpensesParams params) async {
    try {
      List<ExpenseEntity> expenses;

      if (params.query.trim().isEmpty && params.filter == null) {
        // Return recent expenses if no search criteria
        expenses = await _repository.getRecentExpenses(limit: 20);
      } else if (params.filter != null) {
        // Use advanced filtering
        expenses = await _repository.getFilteredExpenses(params.filter!);
      } else {
        // Simple search
        expenses = await _repository.searchExpenses(params.query);
      }

      // Apply post-processing
      expenses = _processSearchResults(expenses, params);

      // Generate search insights
      final insights = _generateSearchInsights(expenses, params);

      return SearchExpensesResult.success(expenses, insights);
    } catch (e) {
      return SearchExpensesResult.failure('Failed to search expenses: $e');
    }
  }

  /// Process search results with additional logic
  List<ExpenseEntity> _processSearchResults(List<ExpenseEntity> expenses, SearchExpensesParams params) {
    // Sort by relevance if query is provided
    if (params.query.trim().isNotEmpty) {
      expenses.sort((a, b) => _calculateRelevanceScore(b, params.query).compareTo(
          _calculateRelevanceScore(a, params.query)));
    }

    // Apply limit if specified
    if (params.limit != null && params.limit! > 0) {
      expenses = expenses.take(params.limit!).toList();
    }

    return expenses;
  }

  /// Calculate relevance score for search results
  double _calculateRelevanceScore(ExpenseEntity expense, String query) {
    double score = 0.0;
    final lowerQuery = query.toLowerCase();
    final lowerDescription = expense.description.toLowerCase();

    // Exact match gets highest score
    if (lowerDescription == lowerQuery) {
      score += 100.0;
    }
    
    // Description starts with query
    else if (lowerDescription.startsWith(lowerQuery)) {
      score += 80.0;
    }
    
    // Description contains query
    else if (lowerDescription.contains(lowerQuery)) {
      score += 60.0;
    }

    // Amount matches (if query is numeric)
    if (double.tryParse(query) != null) {
      final queryAmount = double.parse(query);
      if ((expense.amount - queryAmount).abs() < 0.01) {
        score += 90.0;
      } else if ((expense.amount - queryAmount).abs() < queryAmount * 0.1) {
        score += 40.0;
      }
    }

    // Recent expenses get slight boost
    final daysSinceExpense = DateTime.now().difference(expense.date).inDays;
    if (daysSinceExpense < 7) {
      score += 10.0;
    } else if (daysSinceExpense < 30) {
      score += 5.0;
    }

    return score;
  }

  /// Generate insights about search results
  SearchInsights _generateSearchInsights(List<ExpenseEntity> expenses, SearchExpensesParams params) {
    if (expenses.isEmpty) {
      return SearchInsights.empty();
    }

    final totalAmount = expenses.fold(0.0, (sum, expense) => sum + expense.amount);
    final averageAmount = totalAmount / expenses.length;
    
    // Group by category
    final categoryGroups = <int, List<ExpenseEntity>>{};
    for (final expense in expenses) {
      categoryGroups.putIfAbsent(expense.categoryId, () => []).add(expense);
    }

    // Find date range
    expenses.sort((a, b) => a.date.compareTo(b.date));
    final dateRange = expenses.isNotEmpty ? {
      'start': expenses.first.date,
      'end': expenses.last.date,
    } : null;

    return SearchInsights(
      totalResults: expenses.length,
      totalAmount: totalAmount,
      averageAmount: averageAmount,
      categoryCount: categoryGroups.length,
      dateRange: dateRange,
      hasResults: true,
    );
  }
}

/// Parameters for searching expenses
class SearchExpensesParams {
  final String query;
  final ExpenseFilter? filter;
  final int? limit;

  const SearchExpensesParams({
    required this.query,
    this.filter,
    this.limit,
  });

  /// Helper constructors
  static SearchExpensesParams simple(String query) => SearchExpensesParams(query: query);
  
  static SearchExpensesParams advanced(ExpenseFilter filter) => SearchExpensesParams(
    query: '',
    filter: filter,
  );
}

/// Search insights
class SearchInsights {
  final int totalResults;
  final double totalAmount;
  final double averageAmount;
  final int categoryCount;
  final Map<String, DateTime>? dateRange;
  final bool hasResults;

  const SearchInsights({
    required this.totalResults,
    required this.totalAmount,
    required this.averageAmount,
    required this.categoryCount,
    this.dateRange,
    required this.hasResults,
  });

  factory SearchInsights.empty() => const SearchInsights(
    totalResults: 0,
    totalAmount: 0.0,
    averageAmount: 0.0,
    categoryCount: 0,
    hasResults: false,
  );

  /// Get formatted total amount
  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)}';

  /// Get formatted average amount
  String get formattedAverage => '\$${averageAmount.toStringAsFixed(2)}';
}

/// Result of searching expenses
class SearchExpensesResult {
  final List<ExpenseEntity> expenses;
  final SearchInsights? insights;
  final String? error;
  final bool isSuccess;

  const SearchExpensesResult._({
    this.expenses = const [],
    this.insights,
    this.error,
    required this.isSuccess,
  });

  factory SearchExpensesResult.success(List<ExpenseEntity> expenses, SearchInsights insights) {
    return SearchExpensesResult._(
      expenses: expenses,
      insights: insights,
      isSuccess: true,
    );
  }

  factory SearchExpensesResult.failure(String error) {
    return SearchExpensesResult._(
      error: error,
      isSuccess: false,
    );
  }
}
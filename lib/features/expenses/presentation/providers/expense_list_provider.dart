import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/expense_entity.dart';
import 'expense_provider.dart';

part 'expense_list_provider.g.dart';

@riverpod
class ExpenseList extends _$ExpenseList {
  static const int _pageSize = 20;
  
  // Private state for filters
  String? _currentSearchQuery;

  @override
  Future<List<ExpenseEntity>> build() async {
    return _loadExpenses();
  }

  Future<List<ExpenseEntity>> _loadExpenses({
    int offset = 0,
    int? limit,
    String? searchQuery,
  }) async {
    final repository = ref.read(expenseRepositoryProvider);
    
    // For now, get all expenses and filter manually
    final allExpenses = await repository.getAllExpenses();
    
    // Apply search filter if provided
    List<ExpenseEntity> filteredExpenses = allExpenses;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      filteredExpenses = allExpenses.where((expense) {
        return expense.description.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    // Sort by date (newest first)
    filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
    
    // Apply pagination
    final endIndex = (offset + (limit ?? _pageSize)).clamp(0, filteredExpenses.length);
    return filteredExpenses.sublist(offset.clamp(0, filteredExpenses.length), endIndex);
  }

  /// Load more expenses (pagination)
  Future<void> loadMore() async {
    final currentExpenses = state.value ?? [];
    
    try {
      final moreExpenses = await _loadExpenses(
        offset: currentExpenses.length,
        searchQuery: _currentSearchQuery,
      );

      if (moreExpenses.isNotEmpty) {
        state = AsyncValue.data([...currentExpenses, ...moreExpenses]);
      }
    } catch (error, stack) {
      // Don't update state for pagination errors, just log them
      print('Pagination error: $error');
    }
  }

  /// Refresh the entire list
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    
    try {
      final expenses = await _loadExpenses(
        searchQuery: _currentSearchQuery,
      );
      state = AsyncValue.data(expenses);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  /// Search expenses
  Future<void> search(String query) async {
    _currentSearchQuery = query.trim().isEmpty ? null : query.trim();
    await refresh();
  }

  /// Clear search
  Future<void> clearSearch() async {
    _currentSearchQuery = null;
    await refresh();
  }
}
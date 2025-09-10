import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_provider.dart';
import '../providers/expense_list_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/expense_actions.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/loading_overlay.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends ConsumerStatefulWidget {
  const ExpenseListScreen({super.key});

  static const routeName = '/expenses';

  @override
  ConsumerState<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends ConsumerState<ExpenseListScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshKey = GlobalKey<RefreshIndicatorState>();
  String _searchQuery = '';
  bool _isSelectionMode = false;
  final Set<int> _selectedExpenses = <int>{};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // Load more when near the bottom
      ref.read(expenseListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fix: Use the correct provider and state
    final expenseListAsync = ref.watch(expenseListProvider);
    final expenseListNotifier = ref.read(expenseListProvider.notifier);

    return AppScaffold(
      title: _isSelectionMode ? '${_selectedExpenses.length} Selected' : 'Expenses',
      showBackButton: false,
      actions: [
        if (_isSelectionMode) ...[
          IconButton(
            onPressed: _handleBulkDelete,
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Selected',
          ),
          IconButton(
            onPressed: _handleBulkCategorize,
            icon: const Icon(Icons.category),
            tooltip: 'Categorize Selected',
          ),
          IconButton(
            onPressed: _exitSelectionMode,
            icon: const Icon(Icons.close),
            tooltip: 'Exit Selection',
          ),
        ] else ...[
          IconButton(
            onPressed: () => _showSearchDialog(context),
            icon: const Icon(Icons.search),
            tooltip: 'Search Expenses',
          ),
          IconButton(
            onPressed: () => _showFilterDialog(context),
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Expenses',
          ),
        ],
      ],
      floatingActionButton: _isSelectionMode
          ? null
          : FloatingActionButton.extended(
              heroTag: "addExpenseFAB",
              onPressed: _navigateToAddExpense,
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
            ),
      body: LoadingOverlay(
        isLoading: expenseListAsync.isLoading && !expenseListAsync.hasValue,
        child: Column(
          children: [
            // Search bar (if active)
            if (_searchQuery.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  border: Border(
                    bottom: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Searching: "$_searchQuery"',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _clearSearch(expenseListNotifier),
                      icon: const Icon(Icons.clear),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
            ],

            // Expense list
            Expanded(
              child: RefreshIndicator(
                key: _refreshKey,
                onRefresh: () => expenseListNotifier.refresh(),
                child: expenseListAsync.when(
                  loading: () => const _ExpenseListSkeleton(),
                  error: (error, stack) => _ExpenseListError(
                    error: error.toString(),
                    onRetry: () => expenseListNotifier.refresh(),
                  ),
                  data: (expenses) {
                    if (expenses.isEmpty) {
                      return _EmptyExpenseList(
                        hasFilters: _searchQuery.isNotEmpty,
                        onAddExpense: _navigateToAddExpense,
                        onClearFilters: () {
                          _clearSearch(expenseListNotifier);
                        },
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        final isSelected = _selectedExpenses.contains(expense.id);

                        return ExpenseCard(
                          expense: expense,
                          isSelected: isSelected,
                          isSelectionMode: _isSelectionMode,
                          onTap: () => _handleExpenseTap(expense),
                          onLongPress: () => _handleExpenseLongPress(expense),
                          onSelectionChanged: (selected) => 
                              _handleSelectionChanged(expense.id!, selected),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleExpenseTap(ExpenseEntity expense) {
    if (_isSelectionMode) {
      _handleSelectionChanged(expense.id!, !_selectedExpenses.contains(expense.id));
    } else {
      _showExpenseActions(expense);
    }
  }

  void _handleExpenseLongPress(ExpenseEntity expense) {
    if (!_isSelectionMode) {
      _enterSelectionMode();
      _handleSelectionChanged(expense.id!, true);
    }
  }

  void _handleSelectionChanged(int expenseId, bool selected) {
    setState(() {
      if (selected) {
        _selectedExpenses.add(expenseId);
      } else {
        _selectedExpenses.remove(expenseId);
      }
      
      if (_selectedExpenses.isEmpty && _isSelectionMode) {
        _exitSelectionMode();
      }
    });
  }

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedExpenses.clear();
    });
  }

  void _showExpenseActions(ExpenseEntity expense) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => ExpenseActionsBottomSheet(
        expense: expense,
        onEdit: () => _navigateToEditExpense(expense),
        onDuplicate: () => _handleDuplicateExpense(expense),
        onDelete: () => _handleDeleteExpense(expense),
      ),
    );
  }

  Future<void> _navigateToAddExpense() async {
    final result = await Navigator.pushNamed(
      context,
      AddExpenseScreen.routeName,
    );
    
    if (result != null) {
      // Refresh list after adding
      ref.read(expenseListProvider.notifier).refresh();
    }
  }

  Future<void> _navigateToEditExpense(ExpenseEntity expense) async {
    Navigator.pop(context); // Close bottom sheet
    
    final result = await Navigator.pushNamed(
      context,
      AddExpenseScreen.routeName,
      arguments: {'initialExpense': expense},
    );
    
    if (result != null) {
      // Refresh list after editing
      ref.read(expenseListProvider.notifier).refresh();
    }
  }

  Future<void> _handleDuplicateExpense(ExpenseEntity expense) async {
    Navigator.pop(context); // Close bottom sheet
    
    final result = await Navigator.pushNamed(
      context,
      AddExpenseScreen.routeName,
      arguments: {
        'templateAmount': expense.amount,
        'templateDescription': expense.description,
        'templateCategoryId': expense.categoryId,
      },
    );
    
    if (result != null) {
      ref.read(expenseListProvider.notifier).refresh();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense duplicated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteExpense(ExpenseEntity expense) async {
    Navigator.pop(context); // Close bottom sheet
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(expenseRepositoryProvider).deleteExpense(expense.id!);
        ref.read(expenseListProvider.notifier).refresh();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete expense: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleBulkDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${_selectedExpenses.length} Expenses'),
        content: const Text('Are you sure you want to delete the selected expenses?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final repository = ref.read(expenseRepositoryProvider);
        await Future.wait(
          _selectedExpenses.map((id) => repository.deleteExpense(id)),
        );
        
        ref.read(expenseListProvider.notifier).refresh();
        _exitSelectionMode();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${_selectedExpenses.length} expenses deleted'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete expenses: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handleBulkCategorize() {
    // TODO: Implement bulk categorization
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bulk categorization will be implemented soon'),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (context) {
        String query = _searchQuery;
        return AlertDialog(
          title: const Text('Search Expenses'),
          content: TextField(
            onChanged: (value) => query = value,
            decoration: const InputDecoration(
              hintText: 'Enter search terms...',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, query),
              child: const Text('Search'),
            ),
          ],
        );
      },
    ).then((query) {
      if (query != null) {
        setState(() {
          _searchQuery = query;
        });
        ref.read(expenseListProvider.notifier).search(query);
      }
    });
  }

  void _showFilterDialog(BuildContext context) {
    // TODO: Implement filter dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filter dialog will be implemented soon'),
      ),
    );
  }

  void _clearSearch(ExpenseList notifier) { // Fix: Use ExpenseList instead of ExpenseListNotifier
    setState(() {
      _searchQuery = '';
    });
    notifier.clearSearch();
  }
}

// Keep the helper widgets the same but simplified
class _ExpenseListSkeleton extends StatelessWidget {
  const _ExpenseListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Container(
          height: 80,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpenseListError extends StatelessWidget {
  const _ExpenseListError({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Expenses',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyExpenseList extends StatelessWidget {
  const _EmptyExpenseList({
    required this.hasFilters,
    required this.onAddExpense,
    required this.onClearFilters,
  });

  final bool hasFilters;
  final VoidCallback onAddExpense;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.search_off : Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No Matching Expenses' : 'No Expenses Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your search to find expenses.'
                  : 'Start tracking your spending by adding your first expense.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            if (hasFilters) ...[
              OutlinedButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Search'),
              ),
              const SizedBox(height: 12),
            ],
            ElevatedButton.icon(
              onPressed: onAddExpense,
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Expense'),
            ),
          ],
        ),
      ),
    );
  }
}
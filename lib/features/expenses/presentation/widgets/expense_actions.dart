import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../categories/presentation/providers/category_provider.dart';

class ExpenseActionsBottomSheet extends ConsumerWidget {
  const ExpenseActionsBottomSheet({
    super.key,
    required this.expense,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
    this.onShare,
    this.onAddToFavorites,
  });

  final ExpenseEntity expense;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onAddToFavorites;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoryByIdProvider(expense.categoryId));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 20),

          // Expense summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ExpenseSummaryCard(expense: expense, category: category),
          ),

          const SizedBox(height: 20),

          // Action buttons
          _ActionButton(
            icon: Icons.edit,
            label: 'Edit Expense',
            color: Colors.blue,
            onPressed: onEdit,
          ),
          
          _ActionButton(
            icon: Icons.copy,
            label: 'Duplicate Expense',
            color: Colors.orange,
            onPressed: onDuplicate,
          ),
          
          _ActionButton(
            icon: Icons.share,
            label: 'Share Expense',
            color: Colors.green,
            onPressed: onShare ?? () => _handleShare(context),
          ),
          
          _ActionButton(
            icon: Icons.favorite_border,
            label: 'Add to Favorites',
            color: Colors.pink,
            onPressed: onAddToFavorites ?? () => _handleAddToFavorites(context),
          ),
          
          const Divider(height: 20),
          
          _ActionButton(
            icon: Icons.delete,
            label: 'Delete Expense',
            color: Colors.red,
            onPressed: onDelete,
            isDestructive: true,
          ),
          
          const SizedBox(height: 10),
          
          // Cancel button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ),

          // Safe area padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _handleShare(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality will be implemented soon'),
      ),
    );
  }

  void _handleAddToFavorites(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Favorites functionality will be implemented soon'),
      ),
    );
  }
}

class _ExpenseSummaryCard extends StatelessWidget {
  const _ExpenseSummaryCard({
    required this.expense,
    required this.category,
  });

  final ExpenseEntity expense;
  final AsyncValue category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Category icon
          category.when(
            data: (cat) => Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cat != null 
                    ? Color(cat.colorValue).withOpacity(0.2)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                cat != null 
                    ? IconData(cat.iconCode, fontFamily: 'MaterialIcons')
                    : Icons.help_outline,
                color: cat != null 
                    ? Color(cat.colorValue)
                    : Colors.grey.shade600,
                size: 24,
              ),
            ),
            loading: () => Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const CircularProgressIndicator(),
            ),
            error: (_, __) => Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.error, color: Colors.red.shade600),
            ),
          ),

          const SizedBox(width: 16),

          // Expense details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  CurrencyFormatter.format(expense.amount),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expense.description.isEmpty 
                      ? 'No description'
                      : expense.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: expense.description.isEmpty 
                        ? Colors.grey.shade600
                        : null,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                category.when(
                  data: (cat) => Text(
                    cat?.name ?? 'Unknown Category',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cat != null 
                          ? Color(cat.colorValue)
                          : Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  loading: () => Text(
                    'Loading...',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  error: (_, __) => Text(
                    'Error',
                    style: TextStyle(color: Colors.red.shade600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDestructive 
                ? Colors.red.shade50
                : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDestructive ? Colors.red.shade600 : null,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick action buttons for expense cards
class ExpenseQuickActions extends StatelessWidget {
  const ExpenseQuickActions({
    super.key,
    required this.expense,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
  });

  final ExpenseEntity expense;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit, size: 20),
          color: Colors.blue,
          tooltip: 'Edit',
        ),
        IconButton(
          onPressed: onDuplicate,
          icon: const Icon(Icons.copy, size: 20),
          color: Colors.orange,
          tooltip: 'Duplicate',
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.delete, size: 20),
          color: Colors.red,
          tooltip: 'Delete',
        ),
      ],
    );
  }
}

/// Bulk actions for multiple expense selection
class BulkExpenseActions extends StatelessWidget {
  const BulkExpenseActions({
    super.key,
    required this.selectedCount,
    this.onDelete,
    this.onCategorize,
    this.onExport,
    this.onCancel,
  });

  final int selectedCount;
  final VoidCallback? onDelete;
  final VoidCallback? onCategorize;
  final VoidCallback? onExport;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$selectedCount item${selectedCount != 1 ? 's' : ''} selected',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            IconButton(
              onPressed: onCategorize,
              icon: const Icon(Icons.category),
              tooltip: 'Change Category',
            ),
            IconButton(
              onPressed: onExport,
              icon: const Icon(Icons.share),
              tooltip: 'Export',
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete),
              color: Colors.red,
              tooltip: 'Delete',
            ),
            IconButton(
              onPressed: onCancel,
              icon: const Icon(Icons.close),
              tooltip: 'Cancel',
            ),
          ],
        ),
      ),
    );
  }
}
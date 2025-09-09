import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import '../../../shared/utils/currency_formatter.dart';

class ExpenseCard extends ConsumerWidget {
  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onSelectionChanged,
  });

  final ExpenseEntity expense;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isSelected;
  final bool isSelectionMode;
  final ValueChanged<bool>? onSelectionChanged; // Fix: Remove the nullable type parameter

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoryByIdProvider(expense.categoryId));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        elevation: isSelected ? 8 : 2,
        borderRadius: BorderRadius.circular(12),
        color: isSelected 
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Theme.of(context).cardColor,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    )
                  : null,
            ),
            child: Row(
              children: [
                // Selection checkbox (if in selection mode)
                if (isSelectionMode) ...[
                  Checkbox(
                    value: isSelected,
                    onChanged: onSelectionChanged != null 
                        ? (value) => onSelectionChanged!(value ?? false) // Fix: Handle nullable bool
                        : null,
                    activeColor: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                ],

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
                    child: const Icon(Icons.category, color: Colors.grey),
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
                      // Description and amount row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              expense.description.isEmpty 
                                  ? 'No description'
                                  : expense.description,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: expense.description.isEmpty 
                                    ? Colors.grey.shade600
                                    : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(expense.amount),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Category name and date row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Category name
                          category.when(
                            data: (cat) => Text(
                              cat?.name ?? 'Unknown Category',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

                          // Date and time
                          Text(
                            _formatDateTime(expense.date),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Trailing action indicator
                if (!isSelectionMode) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.more_vert,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expenseDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    final difference = today.difference(expenseDate).inDays;
    
    if (difference == 0) {
      // Today - show time
      final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
      final ampm = dateTime.hour >= 12 ? 'PM' : 'AM';
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return 'Today, $hour:$minute $ampm';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return weekdays[dateTime.weekday - 1];
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/expense_form_provider.dart';
import '../widgets/amount_input.dart';
import '../widgets/category_selector.dart';
import '../../../shared/widgets/date_picker_field.dart';
import '../../../shared/utils/currency_formatter.dart';
import '../../../categories/presentation/providers/category_provider.dart';

class ExpenseForm extends ConsumerWidget {
  const ExpenseForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(expenseFormProvider);
    final formNotifier = ref.read(expenseFormProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Amount Input Section
          _SectionCard(
            title: 'Amount',
            icon: Icons.attach_money,
            child: AmountInput(
              value: formState.amount,
              onChanged: formNotifier.updateAmount,
              hasError: formState.errors.containsKey(ExpenseFormError.amount),
              errorText: formState.errors[ExpenseFormError.amount],
            ),
          ),

          const SizedBox(height: 16),

          // Category Selection Section
          _SectionCard(
            title: 'Category',
            icon: Icons.category,
            isRequired: true,
            child: CategorySelector(
              selectedCategoryId: formState.categoryId,
              onCategorySelected: formNotifier.updateCategory,
              hasError: formState.errors.containsKey(ExpenseFormError.category),
              errorText: formState.errors[ExpenseFormError.category],
            ),
          ),

          const SizedBox(height: 16),

          // Description Section
          _SectionCard(
            title: 'Description',
            icon: Icons.description,
            child: _DescriptionField(
              value: formState.description,
              onChanged: formNotifier.updateDescription,
              hasError: formState.errors.containsKey(ExpenseFormError.description),
              errorText: formState.errors[ExpenseFormError.description],
            ),
          ),

          const SizedBox(height: 16),

          // Date Selection Section
          _SectionCard(
            title: 'Date',
            icon: Icons.calendar_today,
            isRequired: true,
            child: DatePickerField(
              value: formState.date,
              onChanged: formNotifier.updateDate,
              hasError: formState.errors.containsKey(ExpenseFormError.date),
              errorText: formState.errors[ExpenseFormError.date],
              firstDate: DateTime.now().subtract(const Duration(days: 3650)),
              lastDate: DateTime.now().add(const Duration(days: 1)),
            ),
          ),

          const SizedBox(height: 24),

          // Quick Amount Buttons (only for new expenses)
          if (!formState.isEditing) ...[
            _QuickAmountSection(
              onAmountSelected: formNotifier.setQuickAmount,
              currentAmount: formState.amount,
            ),
            const SizedBox(height: 24),
          ],

          // Recent Descriptions (for autocomplete)
          if (formState.description.isEmpty && !formState.isEditing)
            _RecentDescriptionsSection(
              onDescriptionSelected: formNotifier.updateDescription,
            ),

          // Form Summary
          if (formState.amount > 0 && formState.categoryId != null)
            _FormSummaryCard(
              amount: formState.amount,
              categoryId: formState.categoryId!,
              description: formState.description,
              date: formState.date,
            ),

          // Bottom padding for better scrolling
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.isRequired = false,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isRequired) ...[
                  const SizedBox(width: 4),
                  Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _DescriptionField extends ConsumerWidget {
  const _DescriptionField({
    required this.value,
    required this.onChanged,
    required this.hasError,
    this.errorText,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool hasError;
  final String? errorText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch recent descriptions for autocomplete 
    final recentDescriptions = ref.watch(recentDescriptionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          initialValue: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'What was this expense for?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red.shade600),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.red.shade600, width: 2),
            ),
            errorText: hasError ? errorText : null,
            suffixIcon: value.isNotEmpty
                ? IconButton(
                    onPressed: () => onChanged(''),
                    icon: const Icon(Icons.clear),
                  )
                : null,
          ),
          maxLength: 200,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.sentences,
        ),
        
        // Recent descriptions as suggestions
        recentDescriptions.when(
          data: (descriptions) {
            if (descriptions.isEmpty || value.isNotEmpty) {
              return const SizedBox.shrink();
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Recent descriptions:',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: descriptions.take(5).map((desc) => 
                    ActionChip(
                      label: Text(desc),
                      onPressed: () => onChanged(desc),
                      backgroundColor: Theme.of(context).chipTheme.backgroundColor,
                    ),
                  ).toList(),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _QuickAmountSection extends ConsumerWidget {
  const _QuickAmountSection({
    required this.onAmountSelected,
    required this.currentAmount,
  });

  final ValueChanged<double> onAmountSelected;
  final double currentAmount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create a simple list of quick amounts instead of using a provider
    final quickAmounts = [5.0, 10.0, 15.0, 20.0, 25.0, 50.0, 100.0];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Amounts',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: quickAmounts.map((amount) => 
                _QuickAmountChip(
                  amount: amount,
                  isSelected: currentAmount == amount,
                  onPressed: () => onAmountSelected(amount),
                ),
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAmountChip extends StatelessWidget {
  const _QuickAmountChip({
    required this.amount,
    required this.isSelected,
    required this.onPressed,
  });

  final double amount;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(CurrencyFormatter.format(amount)),
      selected: isSelected,
      onSelected: (_) => onPressed(),
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }
}

class _RecentDescriptionsSection extends ConsumerWidget {
  const _RecentDescriptionsSection({
    required this.onDescriptionSelected,
  });

  final ValueChanged<String> onDescriptionSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentDescriptions = ref.watch(recentDescriptionsProvider);

    return recentDescriptions.when(
      data: (descriptions) {
        if (descriptions.isEmpty) return const SizedBox.shrink();
        
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Recent Descriptions',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...descriptions.take(3).map((desc) => 
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.history, size: 16),
                    title: Text(desc),
                    onTap: () => onDescriptionSelected(desc),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _FormSummaryCard extends ConsumerWidget {
  const _FormSummaryCard({
    required this.amount,
    required this.categoryId,
    required this.description,
    required this.date,
  });

  final double amount;
  final int categoryId;
  final String description;
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoryByIdProvider(categoryId));

    return category.when(
      data: (cat) {
        if (cat == null) return const SizedBox.shrink();
        
        return Card(
          elevation: 2,
          color: Theme.of(context).primaryColor.withOpacity(0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Expense Summary',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Amount:'),
                    Text(
                      CurrencyFormatter.format(amount),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Category
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Category:'),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          IconData(cat.iconCode, fontFamily: 'MaterialIcons'),
                          size: 16,
                          color: Color(cat.colorValue),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          cat.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Description
                if (description.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Description:'),
                      Expanded(
                        child: Text(
                          description,
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Date:'),
                    Text(
                      _formatDate(date),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference == -1) {
      return 'Tomorrow';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
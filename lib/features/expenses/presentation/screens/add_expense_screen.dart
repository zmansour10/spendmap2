import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/expense_form.dart' as widgets;
import '../providers/expense_form_provider.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../../../shared/widgets/loading_overlay.dart';

class AddExpenseScreen extends ConsumerWidget {
  const AddExpenseScreen({
    super.key,
    this.initialExpense,
    this.templateAmount,
    this.templateDescription,
    this.templateCategoryId,
  });

  final ExpenseEntity? initialExpense;
  final double? templateAmount;
  final String? templateDescription;
  final int? templateCategoryId;

  static const routeName = '/add-expense';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(expenseFormProvider);
    final formNotifier = ref.read(expenseFormProvider.notifier);

    // Initialize form when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (initialExpense != null) {
        formNotifier.initializeForEdit(initialExpense!);
      } else {
        formNotifier.initializeForCreate(
          templateAmount: templateAmount,
          templateDescription: templateDescription,
          templateCategoryId: templateCategoryId,
        );
      }
    });

    return AppScaffold(
      title: initialExpense != null ? 'Edit Expense' : 'Add Expense',
      showBackButton: true,
      actions: [
        if (formState.isDirty)
          TextButton(
            onPressed: formNotifier.canSave ? () => _handleSave(context, ref) : null,
            child: formState.isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    initialExpense != null ? 'Update' : 'Save',
                    style: TextStyle(
                      color: formNotifier.canSave
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).disabledColor,
                    ),
                  ),
          ),
      ],
      body: LoadingOverlay(
        isLoading: formState.isSubmitting,
        child: Column(
          children: [
            // Form validation summary
            if (formState.errors.isNotEmpty) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.error_outline, 
                             color: Colors.red.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Please fix the following errors:',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...formState.errors.entries.map((error) => 
                      Padding(
                        padding: const EdgeInsets.only(left: 28, top: 2),
                        child: Text(
                          '• ${error.value}',
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Main form
            const Expanded(
              child: widgets.ExpenseForm(),
            ),

            // Bottom action bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 0.5,
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: formState.isSubmitting 
                            ? null 
                            : () => _handleCancel(context, formNotifier),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Save button
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: formNotifier.canSave 
                            ? () => _handleSave(context, ref)
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: formState.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(initialExpense != null ? 'Update Expense' : 'Save Expense'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave(BuildContext context, WidgetRef ref) async {
    final formNotifier = ref.read(expenseFormProvider.notifier);
    
    try {
      final result = await formNotifier.save();
      
      if (!context.mounted) return;
      
      if (result.isSuccess) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              initialExpense != null 
                  ? 'Expense updated successfully'
                  : 'Expense saved successfully',
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Navigate back
        Navigator.of(context).pop(result.expense);
      } else {
        // Show error message
        String errorMessage = 'Failed to save expense';
        
        if (result.hasValidationErrors) {
          errorMessage = result.firstValidationError ?? errorMessage;
        } else if (result.errorMessage != null) {
          errorMessage = result.errorMessage!;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: $e'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleCancel(BuildContext context, ExpenseForm formNotifier) { 
    if (formNotifier.hasUnsavedChanges) {
      showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes?'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard'),
            ),
          ],
        ),
      ).then((shouldDiscard) {
        if (shouldDiscard == true) {
          formNotifier.clear();
          Navigator.of(context).pop();
        }
      });
    } else {
      Navigator.of(context).pop();
    }
  }
}
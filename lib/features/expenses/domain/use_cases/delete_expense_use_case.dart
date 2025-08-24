import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

/// Use case for deleting an expense
class DeleteExpenseUseCase {
  final ExpenseRepository _repository;

  const DeleteExpenseUseCase(this._repository);

  /// Execute the use case
  Future<DeleteExpenseResult> execute(int expenseId) async {
    try {
      // Check if expense exists and get it for logging/audit purposes
      final expense = await _repository.getExpenseById(expenseId);
      if (expense == null) {
        return DeleteExpenseResult.failure('Expense not found');
      }

      // Additional business logic validation
      final businessValidation = _validateBusinessRules(expense);
      if (businessValidation != null) {
        return DeleteExpenseResult.failure(businessValidation);
      }

      // Delete the expense
      await _repository.deleteExpense(expenseId);
      
      return DeleteExpenseResult.success(expense);
    } catch (e) {
      return DeleteExpenseResult.failure('Failed to delete expense: $e');
    }
  }

  // TODO: Validate business rules for deletion
  String? _validateBusinessRules(ExpenseEntity expense) {
    // Business rule: Cannot delete expenses older than X days (for audit purposes)
    final daysSinceCreation = expense.createdAt != null 
        ? DateTime.now().difference(expense.createdAt!).inDays 
        : 0;
    
    if (daysSinceCreation > 90) {
      // Could implement soft delete or require special permission
      // For now, we'll allow it but could add restrictions
    }

    // Business rule: Large expenses might need special confirmation
    if (expense.amount > 1000) {
      // Could require additional confirmation for large expense deletion
    }

    return null; // No validation errors
  }
}

/// Result of deleting an expense
class DeleteExpenseResult {
  final ExpenseEntity? deletedExpense;
  final String? error;
  final bool isSuccess;

  const DeleteExpenseResult._({
    this.deletedExpense,
    this.error,
    required this.isSuccess,
  });

  factory DeleteExpenseResult.success(ExpenseEntity deletedExpense) {
    return DeleteExpenseResult._(
      deletedExpense: deletedExpense,
      isSuccess: true,
    );
  }

  factory DeleteExpenseResult.failure(String error) {
    return DeleteExpenseResult._(
      error: error,
      isSuccess: false,
    );
  }
}
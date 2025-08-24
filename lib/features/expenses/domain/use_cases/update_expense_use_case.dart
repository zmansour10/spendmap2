import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

/// Use case for updating an existing expense
class UpdateExpenseUseCase {
  final ExpenseRepository _repository;

  const UpdateExpenseUseCase(this._repository);

  /// Execute the use case
  Future<UpdateExpenseResult> execute(UpdateExpenseParams params) async {
    try {
      // Check if expense exists
      final existingExpense = await _repository.getExpenseById(params.id);
      if (existingExpense == null) {
        return UpdateExpenseResult.failure('Expense not found');
      }

      // Create updated expense entity
      final updatedExpense = existingExpense.copyWith(
        amount: params.amount,
        description: params.description.trim(),
        categoryId: params.categoryId,
        date: params.date,
        updatedAt: DateTime.now(),
      );

      // Additional business logic validation
      final businessValidation = _validateBusinessRules(existingExpense, updatedExpense);
      if (businessValidation != null) {
        return UpdateExpenseResult.failure(businessValidation);
      }

      // Update the expense
      final result = await _repository.updateExpense(updatedExpense);
      
      return UpdateExpenseResult.success(result);
    } catch (e) {
      return UpdateExpenseResult.failure('Failed to update expense: $e');
    }
  }

  /// Validate business rules for updates
  String? _validateBusinessRules(ExpenseEntity original, ExpenseEntity updated) {
    // Business rule: Significant amount changes might need approval
    if ((updated.amount - original.amount).abs() > original.amount * 0.5) {
      // Large change detected - could add approval workflow
    }

    // Business rule: Date changes might need validation
    if (updated.date.difference(original.date).inDays.abs() > 30) {
      // Date changed by more than 30 days - could add validation
    }

    return null; // No validation errors
  }
}

/// Parameters for updating an expense
class UpdateExpenseParams {
  final int id;
  final double amount;
  final String description;
  final int categoryId;
  final DateTime date;

  const UpdateExpenseParams({
    required this.id,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.date,
  });
}

/// Result of updating an expense
class UpdateExpenseResult {
  final ExpenseEntity? expense;
  final String? error;
  final bool isSuccess;

  const UpdateExpenseResult._({
    this.expense,
    this.error,
    required this.isSuccess,
  });

  factory UpdateExpenseResult.success(ExpenseEntity expense) {
   return UpdateExpenseResult._(
     expense: expense,
     isSuccess: true,
   );
 }

 factory UpdateExpenseResult.failure(String error) {
   return UpdateExpenseResult._(
     error: error,
     isSuccess: false,
   );
 }
}
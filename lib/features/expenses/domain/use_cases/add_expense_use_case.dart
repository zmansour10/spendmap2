import '../entities/expense_entity.dart';
import '../repositories/expense_repository.dart';

/// Use case for adding a new expense
/// Handles validation and business logic for expense creation
class AddExpenseUseCase {
  final ExpenseRepository _repository;

  const AddExpenseUseCase(this._repository);

  /// Execute the use case
  Future<AddExpenseResult> execute(AddExpenseParams params) async {
    try {
      // Create expense entity
      final expense = ExpenseEntity(
        amount: params.amount,
        description: params.description.trim(),
        categoryId: params.categoryId,
        date: params.date,
      );

      // Additional business logic validation
      final businessValidation = _validateBusinessRules(expense);
      if (businessValidation != null) {
        return AddExpenseResult.failure(businessValidation);
      }

      // Create the expense
      final createdExpense = await _repository.createExpense(expense);
      
      return AddExpenseResult.success(createdExpense);
    } catch (e) {
      return AddExpenseResult.failure('Failed to add expense: $e');
    }
  }

  // TODO Validate business rules
  String? _validateBusinessRules(ExpenseEntity expense) {
    // Check for duplicate expense (same amount, category, and date within 1 minute)
    // This could be enhanced to check the database for duplicates
    
    // Business rule: Large expenses (>$1000) might need special handling
    if (expense.amount > 1000) {
      // Could add special validation or flagging for large expenses
    }

    // Business rule: Description recommended for large expenses
    if (expense.amount > 100 && expense.description.trim().isEmpty) {
      // Could return a warning rather than failure
    }

    return null; // No validation errors
  }
}

/// Parameters for adding an expense
class AddExpenseParams {
  final double amount;
  final String description;
  final int categoryId;
  final DateTime date;

  const AddExpenseParams({
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.date,
  });
}

/// Result of adding an expense
class AddExpenseResult {
  final ExpenseEntity? expense;
  final String? error;
  final bool isSuccess;

  const AddExpenseResult._({
    this.expense,
    this.error,
    required this.isSuccess,
  });

  factory AddExpenseResult.success(ExpenseEntity expense) {
    return AddExpenseResult._(
      expense: expense,
      isSuccess: true,
    );
  }

  factory AddExpenseResult.failure(String error) {
    return AddExpenseResult._(
      error: error,
      isSuccess: false,
    );
  }
}
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../categories/presentation/providers/category_provider.dart';
import 'expense_provider.dart';

part 'expense_form_provider.g.dart';

// Expense Form State Provider
@riverpod
class ExpenseForm extends _$ExpenseForm {
  @override
  ExpenseFormState build() {
    return ExpenseFormState.initial();
  }

  /// Initialize form for editing existing expense
  void initializeForEdit(ExpenseEntity expense) {
    state = ExpenseFormState(
      id: expense.id,
      amount: expense.amount,
      description: expense.description,
      categoryId: expense.categoryId,
      date: expense.date,
      isEditing: true,
      originalExpense: expense,
      isDirty: false,
      errors: {},
    );
  }

  /// Initialize form for creating new expense
  void initializeForCreate({
    double? templateAmount,
    String? templateDescription,
    int? templateCategoryId,
    DateTime? templateDate,
  }) {
    state = ExpenseFormState(
      id: null,
      amount: templateAmount ?? 0.0,
      description: templateDescription ?? '',
      categoryId: templateCategoryId,
      date: templateDate ?? DateTime.now(),
      isEditing: false,
      originalExpense: null,
      isDirty:
          templateAmount != null ||
          templateDescription != null ||
          templateCategoryId != null ||
          templateDate != null,
      errors: {},
    );
  }

  /// Update expense amount
  void updateAmount(double amount) {
    final updatedErrors = Map<ExpenseFormError, String>.from(state.errors);
    updatedErrors.remove(ExpenseFormError.amount);

    state = state.copyWith(
      amount: amount,
      isDirty: true,
      errors: updatedErrors,
    );

    // Validate amount immediately
    final amountError = _validateAmountSync(amount);
    if (amountError != null) {
      state = state.copyWith(
        errors: {...state.errors, ExpenseFormError.amount: amountError},
      );
    }
  }

  /// Update expense description
  void updateDescription(String description) {
    final trimmedDescription = description.trim();

    final updatedErrors = Map<ExpenseFormError, String>.from(state.errors);
    updatedErrors.remove(ExpenseFormError.description);

    state = state.copyWith(
      description: trimmedDescription,
      isDirty: true,
      errors: updatedErrors,
    );

    // Validate description if provided
    if (trimmedDescription.isNotEmpty) {
      final descriptionError = _validateDescriptionSync(trimmedDescription);
      if (descriptionError != null) {
        state = state.copyWith(
          errors: {
            ...state.errors,
            ExpenseFormError.description: descriptionError,
          },
        );
      }
    }
  }

  /// Update expense category
  void updateCategory(int? categoryId) {
    final updatedErrors = Map<ExpenseFormError, String>.from(state.errors);
    updatedErrors.remove(ExpenseFormError.category);

    state = state.copyWith(
      categoryId: categoryId,
      isDirty: true,
      errors: updatedErrors,
    );

    // Validate category immediately
    final categoryError = _validateCategorySync(categoryId);
    if (categoryError != null) {
      state = state.copyWith(
        errors: {...state.errors, ExpenseFormError.category: categoryError},
      );
    }
  }

  /// Update expense date
  void updateDate(DateTime date) {
    final updatedErrors = Map<ExpenseFormError, String>.from(state.errors);
    updatedErrors.remove(ExpenseFormError.date);

    state = state.copyWith(date: date, isDirty: true, errors: updatedErrors);

    // Validate date immediately
    final dateError = _validateDateSync(date);
    if (dateError != null) {
      state = state.copyWith(
        errors: {...state.errors, ExpenseFormError.date: dateError},
      );
    }
  }

  /// Set amount from string (for text field input)
  void updateAmountFromString(String amountString) {
    final trimmed = amountString.trim();
    if (trimmed.isEmpty) {
      updateAmount(0.0);
      return;
    }

    final parsed = double.tryParse(trimmed);
    if (parsed != null) {
      updateAmount(parsed);
    } else {
      state = state.copyWith(
        errors: {
          ...state.errors,
          ExpenseFormError.amount: 'Invalid amount format',
        },
      );
    }
  }

  /// Validate the entire form
  Future<bool> validateForm() async {
    final errors = <ExpenseFormError, String>{};

    // Validate amount
    final amountError = _validateAmountSync(state.amount);
    if (amountError != null) {
      errors[ExpenseFormError.amount] = amountError;
    }

    // Validate description
    final descriptionError = _validateDescriptionSync(state.description);
    if (descriptionError != null) {
      errors[ExpenseFormError.description] = descriptionError;
    }

    // Validate category
    final categoryError = _validateCategorySync(state.categoryId);
    if (categoryError != null) {
      errors[ExpenseFormError.category] = categoryError;
    }

    // Validate date
    final dateError = _validateDateSync(state.date);
    if (dateError != null) {
      errors[ExpenseFormError.date] = dateError;
    }

    // Additional async validations if needed
    if (state.categoryId != null) {
      final categoryExists = await _validateCategoryExists(state.categoryId!);
      if (!categoryExists) {
        errors[ExpenseFormError.category] =
            'Selected category no longer exists';
      }
    }

    state = state.copyWith(errors: errors);
    return errors.isEmpty;
  }

  /// Save the expense (create or update)
  Future<ExpenseFormResult> save() async {
    state = state.copyWith(isSubmitting: true);

    try {
      // Validate form first
      final isValid = await validateForm();
      if (!isValid) {
        state = state.copyWith(isSubmitting: false);
        return ExpenseFormResult.validationError(state.errors);
      }

      final expensesNotifier = ref.read(expensesProvider.notifier);
      final expenseEntity = state.toEntity();

      ExpenseEntity savedExpense;

      if (state.isEditing && state.id != null) {
        // Update existing expense
        savedExpense = await expensesNotifier.updateExpense(expenseEntity);
      } else {
        // Create new expense
        savedExpense = await expensesNotifier.addExpense(expenseEntity);
      }

      // Update form state with saved data
      state = state.copyWith(
        id: savedExpense.id,
        amount: savedExpense.amount,
        description: savedExpense.description,
        categoryId: savedExpense.categoryId,
        date: savedExpense.date,
        isDirty: false,
        isSubmitting: false,
        errors: {},
        originalExpense: savedExpense,
      );

      return ExpenseFormResult.success(savedExpense);
    } catch (e) {
      state = state.copyWith(isSubmitting: false);

      // Parse specific error messages
      String errorMessage = e.toString();
      if (errorMessage.contains('category')) {
        state = state.copyWith(
          errors: {
            ...state.errors,
            ExpenseFormError.category: 'Invalid category selected',
          },
        );
        return ExpenseFormResult.validationError(state.errors);
      }

      return ExpenseFormResult.saveError(errorMessage);
    }
  }

  /// Reset form to original state (for editing) or initial state (for creating)
  void reset() {
    if (state.originalExpense != null) {
      initializeForEdit(state.originalExpense!);
    } else {
      initializeForCreate();
    }
  }

  /// Clear all form data
  void clear() {
    state = ExpenseFormState.initial();
  }

  /// Apply similar expense data
  void applySimilarExpense(ExpenseEntity similarExpense) {
    state = state.copyWith(
      amount: similarExpense.amount,
      description: similarExpense.description,
      categoryId: similarExpense.categoryId,
      // Don't copy date - keep current/selected date
      isDirty: true,
    );
  }

  /// Quick set for common amounts
  void setQuickAmount(double amount) {
    updateAmount(amount);
  }

  /// Synchronous validation methods
  String? _validateAmountSync(double amount) {
    if (amount <= 0) {
      return 'Amount must be greater than zero';
    }
    if (amount > 999999.99) {
      return 'Amount cannot exceed \$999,999.99';
    }
    return null;
  }

  String? _validateDescriptionSync(String description) {
    if (description.length > 200) {
      return 'Description cannot exceed 200 characters';
    }
    return null;
  }

  String? _validateCategorySync(int? categoryId) {
    if (categoryId == null || categoryId <= 0) {
      return 'Please select a category';
    }
    return null;
  }

  String? _validateDateSync(DateTime date) {
    final now = DateTime.now();
    final futureLimit = now.add(const Duration(days: 1));

    if (date.isAfter(futureLimit)) {
      return 'Expense date cannot be more than 1 day in the future';
    }

    final pastLimit = now.subtract(const Duration(days: 3650)); // 10 years
    if (date.isBefore(pastLimit)) {
      return 'Expense date cannot be more than 10 years in the past';
    }

    return null;
  }

  /// Async validation methods
  Future<bool> _validateCategoryExists(int categoryId) async {
    try {
      final category = await ref.read(categoryByIdProvider(categoryId).future);
      return category != null && category.isActive;
    } catch (e) {
      return false;
    }
  }

  /// Check if form has unsaved changes
  // bool get hasUnsavedChanges => state.isDirty;
  bool get hasUnsavedChanges {
    return state.isDirty && (
      state.amount > 0 ||
      state.description.isNotEmpty ||
      state.categoryId != null
    );
  }

  /// Get current form validation state
  bool get isValid {
    final hasValidAmount = state.amount > 0 && state.amount <= 999999.99;
    final hasValidCategory = state.categoryId != null && state.categoryId! > 0;
    final hasValidDate = !state.date.isAfter(
      DateTime.now().add(const Duration(days: 1)),
    );
    final hasValidDescription = state.description.length <= 200;

    return hasValidAmount &&
        hasValidCategory &&
        hasValidDate &&
        hasValidDescription &&
        state.errors.isEmpty;
  }

  /// Check if form can be saved
  bool get canSave {
    return isValid && !state.isSubmitting;
  }
}

// Quick Amount Options Provider
@riverpod
List<double> quickAmountOptions(QuickAmountOptionsRef ref) {
  return [5.0, 10.0, 15.0, 20.0, 25.0, 50.0, 100.0];
}



// Recent Descriptions Provider (for autocomplete)
// @riverpod
// Future<List<String>> recentDescriptions(RecentDescriptionsRef ref, {int limit = 10}) async {
//   final repository = ref.watch(expenseRepositoryProvider);
//   final recentExpenses = await repository.getRecentExpenses(limit: 20);

//   // Extract unique descriptions
//   final descriptions = recentExpenses
//       .where((expense) => expense.description.trim().isNotEmpty)
//       .map((expense) => expense.description)
//       .toSet()
//       .take(limit)
//       .toList();

//   return descriptions;
// }

@riverpod
Future<List<String>> recentDescriptions(RecentDescriptionsRef ref) async {
  final expenseRepository = ref.watch(expenseRepositoryProvider);
  final expenses = await expenseRepository.getRecentExpenses(limit: 20);
  
  // Get unique descriptions, excluding empty ones
  final descriptions = expenses
      .map((e) => e.description.trim())
      .where((desc) => desc.isNotEmpty)
      .toSet()
      .toList();
  
  return descriptions;
}


/// Expense form state
class ExpenseFormState {
  final int? id;
  final double amount;
  final String description;
  final int? categoryId;
  final DateTime date;
  final bool isEditing;
  final ExpenseEntity? originalExpense;
  final bool isDirty;
  final bool isSubmitting;
  final Map<ExpenseFormError, String> errors;

  const ExpenseFormState({
    this.id,
    required this.amount,
    required this.description,
    this.categoryId,
    required this.date,
    required this.isEditing,
    this.originalExpense,
    required this.isDirty,
    this.isSubmitting = false,
    required this.errors,
  });

  factory ExpenseFormState.initial() {
    return ExpenseFormState(
      amount: 0.0,
      description: '',
      categoryId: null,
      date: DateTime.now(),
      isEditing: false,
      isDirty: false,
      errors: {},
    );
  }

  ExpenseFormState copyWith({
    int? id,
    double? amount,
    String? description,
    int? categoryId,
    DateTime? date,
    bool? isEditing,
    ExpenseEntity? originalExpense,
    bool? isDirty,
    bool? isSubmitting,
    Map<ExpenseFormError, String>? errors,
  }) {
    return ExpenseFormState(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      isEditing: isEditing ?? this.isEditing,
      originalExpense: originalExpense ?? this.originalExpense,
      isDirty: isDirty ?? this.isDirty,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errors: errors ?? this.errors,
    );
  }

  /// Convert form state to expense entity
  ExpenseEntity toEntity() {
    return ExpenseEntity(
      id: id,
      amount: amount,
      description: description,
      categoryId: categoryId!,
      date: date,
      createdAt: originalExpense?.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Get form validation summary
  ExpenseFormValidation get validation {
    final hasValidAmount = amount > 0 && amount <= 999999.99;
    final hasValidCategory = categoryId != null && categoryId! > 0;
    // final hasValidDate = !date.isAfter(DateTime.now().add(const Duration(days: 1)));
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final hasValidDate = date.isBefore(tomorrow);

    final hasValidDescription = description.length <= 200;

    final isValid =
        hasValidAmount &&
        hasValidCategory &&
        hasValidDate &&
        hasValidDescription &&
        errors.isEmpty;

    final hasErrors = errors.isNotEmpty;

    return ExpenseFormValidation(
      isValid: isValid,
      hasErrors: hasErrors,
      errorCount: errors.length,
      errors: errors,
    );
  }

  /// Check if form has changes from original
  bool get hasChanges {
    if (originalExpense == null) return isDirty;

    return amount != originalExpense!.amount ||
        description != originalExpense!.description ||
        categoryId != originalExpense!.categoryId ||
        !_isSameDay(date, originalExpense!.date);
  }

  /// Get formatted amount
  String get formattedAmount => amount == 0.0 ? '' : amount.toStringAsFixed(2);

  /// Check if date is same day (ignore time)
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  @override
  String toString() {
    return 'ExpenseFormState(id: $id, amount: $amount, categoryId: $categoryId, isEditing: $isEditing, isDirty: $isDirty, errors: ${errors.length})';
  }
}

/// Form validation errors
enum ExpenseFormError { amount, description, category, date, network }

/// Form validation result
class ExpenseFormValidation {
  final bool isValid;
  final bool hasErrors;
  final int errorCount;
  final Map<ExpenseFormError, String> errors;

  const ExpenseFormValidation({
    required this.isValid,
    required this.hasErrors,
    required this.errorCount,
    required this.errors,
  });

  String? getError(ExpenseFormError field) => errors[field];
  bool hasError(ExpenseFormError field) => errors.containsKey(field);

  /// Get first error message for display
  String? get firstErrorMessage {
    if (errors.isEmpty) return null;
    return errors.values.first;
  }

  /// Get all error messages as a list
  List<String> get allErrorMessages => errors.values.toList();
}

/// Form operation result
class ExpenseFormResult {
  final bool isSuccess;
  final ExpenseEntity? expense;
  final String? errorMessage;
  final Map<ExpenseFormError, String>? validationErrors;

  const ExpenseFormResult._({
    required this.isSuccess,
    this.expense,
    this.errorMessage,
    this.validationErrors,
  });

  factory ExpenseFormResult.success(ExpenseEntity expense) {
    return ExpenseFormResult._(isSuccess: true, expense: expense);
  }

  factory ExpenseFormResult.saveError(String message) {
    return ExpenseFormResult._(isSuccess: false, errorMessage: message);
  }

  factory ExpenseFormResult.validationError(
    Map<ExpenseFormError, String> errors,
  ) {
    return ExpenseFormResult._(isSuccess: false, validationErrors: errors);
  }

  /// Check if result has validation errors
  bool get hasValidationErrors =>
      validationErrors != null && validationErrors!.isNotEmpty;

  /// Get first validation error message
  String? get firstValidationError {
    if (validationErrors == null || validationErrors!.isEmpty) return null;
    return validationErrors!.values.first;
  }
}

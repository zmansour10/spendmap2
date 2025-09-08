import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendmap2/features/expenses/domain/entities/expense_entity.dart';
import 'package:spendmap2/features/expenses/presentation/providers/expense_form_provider.dart';
import 'package:spendmap2/features/expenses/presentation/providers/expense_filter_provider.dart';

void main() {
  group('Expense State Management Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Expense Form Provider', () {
      test('should initialize with correct default state', () {
        final formState = container.read(expenseFormProvider);

        expect(formState.amount, equals(0.0));
        expect(formState.description, equals(''));
        expect(formState.categoryId, isNull);
        expect(formState.isEditing, isFalse);
        expect(formState.isDirty, isFalse);
        expect(formState.isSubmitting, isFalse);
        expect(formState.errors, isEmpty);
      });

      test('should update amount and mark as dirty', () {
        final formNotifier = container.read(expenseFormProvider.notifier);

        formNotifier.updateAmount(25.50);

        final formState = container.read(expenseFormProvider);
        expect(formState.amount, equals(25.50));
        expect(formState.isDirty, isTrue);
        expect(formState.errors, isNot(contains(ExpenseFormError.amount)));
      });

      test('should validate amount correctly', () {
        final formNotifier = container.read(expenseFormProvider.notifier);

        // Zero amount should create error
        formNotifier.updateAmount(0.0);
        final zeroState = container.read(expenseFormProvider);
        expect(zeroState.errors, contains(ExpenseFormError.amount));

        // Valid amount should clear error
        formNotifier.updateAmount(25.50);
        final validState = container.read(expenseFormProvider);
        expect(validState.errors, isNot(contains(ExpenseFormError.amount)));

        // Too large amount should create error
        formNotifier.updateAmount(1000000.0);
        final largeState = container.read(expenseFormProvider);
        expect(largeState.errors, contains(ExpenseFormError.amount));
      });

      test('should handle amount from string correctly', () {
        final formNotifier = container.read(expenseFormProvider.notifier);

        // Valid string
        formNotifier.updateAmountFromString('25.50');
        final validState = container.read(expenseFormProvider);
        expect(validState.amount, equals(25.50));

        // Invalid string
        formNotifier.updateAmountFromString('invalid');
        final invalidState = container.read(expenseFormProvider);
        expect(invalidState.errors, contains(ExpenseFormError.amount));

        // Empty string
        formNotifier.updateAmountFromString('');
        final emptyState = container.read(expenseFormProvider);
        expect(emptyState.amount, equals(0.0));
      });

      test('should update description and validate length', () {
        final formNotifier = container.read(expenseFormProvider.notifier);

        // Valid description
        formNotifier.updateDescription('Coffee and pastry');
        final validState = container.read(expenseFormProvider);
        expect(validState.description, equals('Coffee and pastry'));
        expect(validState.isDirty, isTrue);

        // Too long description
        final longDescription = 'a' * 201;
        formNotifier.updateDescription(longDescription);
        final longState = container.read(expenseFormProvider);
        expect(longState.errors, contains(ExpenseFormError.description));
      });

      test('should update category and validate', () {
        final formNotifier = container.read(expenseFormProvider.notifier);

        // Valid category
        formNotifier.updateCategory(1);
        final validState = container.read(expenseFormProvider);
        expect(validState.categoryId, equals(1));
        expect(validState.isDirty, isTrue);
        expect(validState.errors, isNot(contains(ExpenseFormError.category)));

        // Null category should create error
        formNotifier.updateCategory(null);
        final nullState = container.read(expenseFormProvider);
        expect(nullState.errors, contains(ExpenseFormError.category));
      });

      test('should update date and validate', () {
        final formNotifier = container.read(expenseFormProvider.notifier);
        final now = DateTime.now();
        final validDate = now.subtract(const Duration(days: 1));

        // Valid date
        formNotifier.updateDate(validDate);
        final validState = container.read(expenseFormProvider);
        expect(validState.date, equals(validDate));
        expect(validState.isDirty, isTrue);

        // Future date should create error
        final futureDate = now.add(const Duration(days: 2));
        formNotifier.updateDate(futureDate);
        final futureState = container.read(expenseFormProvider);
        expect(futureState.errors, contains(ExpenseFormError.date));

        // Very old date should create error
        final oldDate = now.subtract(const Duration(days: 4000));
        formNotifier.updateDate(oldDate);
        final oldState = container.read(expenseFormProvider);
        expect(oldState.errors, contains(ExpenseFormError.date));
      });

      test('should initialize for edit correctly', () {
        final formNotifier = container.read(expenseFormProvider.notifier);
        final expense = ExpenseEntity(
          id: 1,
          amount: 25.50,
          description: 'Test expense',
          categoryId: 2,
          date: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        formNotifier.initializeForEdit(expense);

        final formState = container.read(expenseFormProvider);
        expect(formState.id, equals(1));
        expect(formState.amount, equals(25.50));
        expect(formState.description, equals('Test expense'));
        expect(formState.categoryId, equals(2));
        expect(formState.isEditing, isTrue);
        expect(formState.originalExpense, equals(expense));
        expect(formState.isDirty, isFalse);
      });

      test('should initialize for create with template', () {
        final formNotifier = container.read(expenseFormProvider.notifier);

        formNotifier.initializeForCreate(
          templateAmount: 15.75,
          templateDescription: 'Lunch',
          templateCategoryId: 3,
        );

        final formState = container.read(expenseFormProvider);
        expect(formState.amount, equals(15.75));
        expect(formState.description, equals('Lunch'));
        expect(formState.categoryId, equals(3));
        expect(formState.isEditing, isFalse);
        expect(formState.isDirty, isTrue);
      });

      test('should create expense entity from form state', () {
        final formNotifier = container.read(expenseFormProvider.notifier);

        formNotifier.updateAmount(30.00);
        formNotifier.updateDescription('Dinner');
        formNotifier.updateCategory(4);
        final testDate = DateTime.now();
        formNotifier.updateDate(testDate);

        final formState = container.read(expenseFormProvider);
        final entity = formState.toEntity();

        expect(entity.amount, equals(30.00));
        expect(entity.description, equals('Dinner'));
        expect(entity.categoryId, equals(4));
        expect(entity.date, equals(testDate));
      });

      test('should handle form validation', () {
        final formNotifier = container.read(expenseFormProvider.notifier);

        // Start with a clean form (this is important!)
        formNotifier.clear(); // or initializeForCreate()

        // Empty form should be invalid due to missing required fields
        final initialState = container.read(expenseFormProvider);
        expect(initialState.validation.isValid, isFalse);

        // Set valid data in the correct order to avoid validation errors
        formNotifier.updateAmount(25.50);
        formNotifier.updateCategory(1);
        formNotifier.updateDescription('Valid expense'); // Optional but helps
        formNotifier.updateDate(DateTime.now());

        final validState = container.read(expenseFormProvider);
        final validValidation = validState.validation;

        // Debug output for troubleshooting
        print(
          'Amount: ${validState.amount} (valid: ${validState.amount > 0 && validState.amount <= 999999.99})',
        );
        print(
          'Category: ${validState.categoryId} (valid: ${validState.categoryId != null && validState.categoryId! > 0})',
        );
        print(
          'Description length: ${validState.description.length} (valid: ${validState.description.length <= 200})',
        );
        print(
          'Date: ${validState.date} (valid: ${!validState.date.isAfter(DateTime.now().add(const Duration(days: 1)))})',
        );
        print('Errors: ${validState.errors}');
        print('Validation isValid: ${validValidation.isValid}');
        print('Validation hasErrors: ${validValidation.hasErrors}');

        expect(validValidation.isValid, isTrue);
        expect(validValidation.hasErrors, isFalse);
        expect(validState.errors.isEmpty, isTrue);
      });

      test('should handle form validation step by step', () {
        final formNotifier = container.read(expenseFormProvider.notifier);

        // Start completely fresh
        formNotifier.initializeForCreate();

        // Check initial state - should be invalid due to missing required fields
        var currentState = container.read(expenseFormProvider);
        expect(
          currentState.validation.isValid,
          isFalse,
          reason: 'Empty form should be invalid',
        );

        // Set amount first
        formNotifier.updateAmount(25.50);
        currentState = container.read(expenseFormProvider);
        expect(
          currentState.errors.containsKey(ExpenseFormError.amount),
          isFalse,
          reason: 'Valid amount should not have errors',
        );

        // Set category
        formNotifier.updateCategory(1);
        currentState = container.read(expenseFormProvider);
        expect(
          currentState.errors.containsKey(ExpenseFormError.category),
          isFalse,
          reason: 'Valid category should not have errors',
        );

        // At this point, all required fields should be valid
        expect(currentState.amount > 0, isTrue);
        expect(
          currentState.categoryId != null && currentState.categoryId! > 0,
          isTrue,
        );
        expect(currentState.description.length <= 200, isTrue);
        expect(
          !currentState.date.isAfter(
            DateTime.now().add(const Duration(days: 1)),
          ),
          isTrue,
        );
        expect(
          currentState.errors.isEmpty,
          isTrue,
          reason: 'Should have no validation errors',
        );

        // Now the form should be valid
        expect(currentState.validation.isValid, isTrue);
      });

      test('should handle form validation - simplified', () {
        final formNotifier = container.read(expenseFormProvider.notifier);

        // Start fresh
        formNotifier.initializeForCreate();

        // Set all required valid data
        formNotifier.updateAmount(25.50);
        formNotifier.updateCategory(1);
        // Description is optional, so don't set it

        final validState = container.read(expenseFormProvider);

        // Check individual validation components
        expect(validState.amount > 0, isTrue);
        expect(validState.categoryId != null, isTrue);
        expect(validState.categoryId! > 0, isTrue);
        expect(validState.description.length <= 200, isTrue);
        expect(validState.errors.isEmpty, isTrue);

        // Now check the computed validation
        expect(validState.validation.isValid, isTrue);
      });

      test('should apply similar expense data', () {
        final formNotifier = container.read(expenseFormProvider.notifier);
        final similarExpense = ExpenseEntity(
          id: 2,
          amount: 12.99,
          description: 'Similar coffee',
          categoryId: 1,
          date: DateTime.now().subtract(const Duration(days: 1)),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        formNotifier.applySimilarExpense(similarExpense); 

        final formState = container.read(expenseFormProvider);
        expect(formState.amount, equals(12.99));
        expect(formState.description, equals('Similar coffee'));
        expect(formState.categoryId, equals(1));
        expect(formState.isDirty, isTrue);
        // Date should not be copied
        expect(formState.date, isNot(equals(similarExpense.date)));
      });

      test('should check if form can be saved', () {
        final formNotifier = container.read(expenseFormProvider.notifier);

        // Invalid form cannot be saved
        expect(formNotifier.canSave, isFalse);

        // Valid form can be saved
        formNotifier.updateAmount(25.50);
        formNotifier.updateCategory(1);
        formNotifier.updateDate(DateTime.now());

        expect(formNotifier.canSave, isTrue);

        // Form being submitted cannot be saved again
        final currentState = container.read(expenseFormProvider);
        final submittingState = currentState.copyWith(isSubmitting: true);
        container.read(expenseFormProvider.notifier).state = submittingState;

        expect(formNotifier.canSave, isFalse);
      });
    });

    group('Expense Filter Controller', () {
      test('should initialize with default filter state', () {
        final filterState = container.read(expenseFilterControllerProvider);

        expect(filterState.searchQuery, equals(''));
        expect(filterState.startDate, isNull);
        expect(filterState.endDate, isNull);
        expect(filterState.minAmount, isNull);
        expect(filterState.maxAmount, isNull);
        expect(filterState.categoryIds, isNull);
        expect(filterState.sortOption, equals(ExpenseSortOption.dateNewest));
        expect(filterState.sortAscending, isFalse);
        expect(filterState.timePeriod, equals(ExpenseTimePeriod.all));
        expect(filterState.hasActiveFilters, isFalse);
      });

      test('should handle date range updates', () {
        final filterNotifier = container.read(
          expenseFilterControllerProvider.notifier,
        );
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 31);

        filterNotifier.setDateRange(startDate, endDate);

        final filterState = container.read(expenseFilterControllerProvider);
        expect(filterState.startDate, equals(startDate));
        expect(filterState.endDate, equals(endDate));
        expect(filterState.hasActiveFilters, isTrue);
      });

      test('should handle amount range updates', () {
        final filterNotifier = container.read(
          expenseFilterControllerProvider.notifier,
        );

        filterNotifier.setAmountRange(10.0, 100.0);

        final filterState = container.read(expenseFilterControllerProvider);
        expect(filterState.minAmount, equals(10.0));
        expect(filterState.maxAmount, equals(100.0));
        expect(filterState.hasActiveFilters, isTrue);
      });

      test('should handle category filter updates', () {
        final filterNotifier = container.read(
          expenseFilterControllerProvider.notifier,
        );

        filterNotifier.setCategoryFilter([1, 2, 3]);

        final filterState = container.read(expenseFilterControllerProvider);
        expect(filterState.categoryIds, equals([1, 2, 3]));
        expect(filterState.hasActiveFilters, isTrue);
      });

      test('should add and remove categories from filter', () {
        final filterNotifier = container.read(
          expenseFilterControllerProvider.notifier,
        );

        // Add categories
        filterNotifier.addCategoryToFilter(1);
        filterNotifier.addCategoryToFilter(2);

        final stateWithCategories = container.read(
          expenseFilterControllerProvider,
        );
        expect(stateWithCategories.categoryIds, equals([1, 2]));

        // Try to add duplicate (should be ignored)
        filterNotifier.addCategoryToFilter(1);
        final stateNoDuplicate = container.read(
          expenseFilterControllerProvider,
        );
        expect(stateNoDuplicate.categoryIds, equals([1, 2]));

        // Remove category
        filterNotifier.removeCategoryFromFilter(1);
        final stateAfterRemove = container.read(
          expenseFilterControllerProvider,
        );
        expect(stateAfterRemove.categoryIds, equals([2]));
      });

      test('should handle search query updates', () {
        final filterNotifier = container.read(
          expenseFilterControllerProvider.notifier,
        );

        filterNotifier.setSearchQuery('  coffee  ');

        final filterState = container.read(expenseFilterControllerProvider);
        expect(filterState.searchQuery, equals('coffee')); 
        expect(filterState.hasActiveFilters, isTrue);
      });

      test('should handle sort option updates', () {
        final filterNotifier = container.read(
          expenseFilterControllerProvider.notifier,
        );

        filterNotifier.setSortOption(ExpenseSortOption.amountHighest);

        final filterState = container.read(expenseFilterControllerProvider);
        expect(filterState.sortOption, equals(ExpenseSortOption.amountHighest));

        // Test toggle sort direction
        filterNotifier.toggleSortDirection();
        final toggledState = container.read(expenseFilterControllerProvider);
        expect(toggledState.sortAscending, isTrue);
      });

      test('should handle time period updates', () {
        final filterNotifier = container.read(
          expenseFilterControllerProvider.notifier,
        );

        filterNotifier.setTimePeriod(ExpenseTimePeriod.thisMonth);

        final filterState = container.read(expenseFilterControllerProvider);
        expect(filterState.timePeriod, equals(ExpenseTimePeriod.thisMonth));
        expect(filterState.startDate, isNotNull);
        expect(filterState.endDate, isNotNull);

        // Start date should be first of current month
        final now = DateTime.now();
        final expectedStart = DateTime(now.year, now.month, 1);
        expect(filterState.startDate!.year, equals(expectedStart.year));
        expect(filterState.startDate!.month, equals(expectedStart.month));
        expect(filterState.startDate!.day, equals(expectedStart.day));
      });

      test('should handle preset filters', () {
        final filterNotifier = container.read(
          expenseFilterControllerProvider.notifier,
        );

        filterNotifier.applyPresetFilter(ExpenseFilterPreset.largeExpenses);

        final filterState = container.read(expenseFilterControllerProvider);
        expect(filterState.minAmount, equals(200.0));
        expect(filterState.sortOption, equals(ExpenseSortOption.amountHighest));
        expect(filterState.timePeriod, equals(ExpenseTimePeriod.all));
      });

      test('should clear filters correctly', () {
        final filterNotifier = container.read(
          expenseFilterControllerProvider.notifier,
        );

        // Set some filters
        filterNotifier.setSearchQuery('test');
        filterNotifier.setAmountRange(10.0, 100.0);
        filterNotifier.setCategoryFilter([1, 2]);

        // Verify filters are set
        final stateWithFilters = container.read(
          expenseFilterControllerProvider,
        );
        expect(stateWithFilters.hasActiveFilters, isTrue);

        // Clear all filters
        filterNotifier.clearAllFilters();

        final clearedState = container.read(expenseFilterControllerProvider);
        expect(clearedState.hasActiveFilters, isFalse);
        expect(clearedState.searchQuery, equals(''));
        expect(clearedState.minAmount, isNull);
        expect(clearedState.maxAmount, isNull);
        expect(clearedState.categoryIds, isNull);
      });

      test('should clear specific filters', () {
        final filterNotifier = container.read(
          expenseFilterControllerProvider.notifier,
        );

        // Set multiple filters
        filterNotifier.setSearchQuery('test');
        filterNotifier.setAmountRange(10.0, 100.0);
        filterNotifier.setDateRange(
          DateTime(2024, 1, 1),
          DateTime(2024, 1, 31),
        );
        filterNotifier.setCategoryFilter([1, 2]);

        // Verify all filters are set
        final stateWithAllFilters = container.read(
          expenseFilterControllerProvider,
        );
        expect(stateWithAllFilters.startDate, isNotNull);
        expect(stateWithAllFilters.endDate, isNotNull);
        expect(stateWithAllFilters.minAmount, isNotNull);
        expect(stateWithAllFilters.maxAmount, isNotNull);
        expect(stateWithAllFilters.categoryIds, isNotNull);
        expect(stateWithAllFilters.searchQuery, isNotEmpty);

        // Clear only date filter
        filterNotifier.clearDateFilter();
        final stateAfterDateClear = container.read(
          expenseFilterControllerProvider,
        );
        expect(stateAfterDateClear.startDate, isNull);
        expect(stateAfterDateClear.endDate, isNull);
        expect(stateAfterDateClear.timePeriod, equals(ExpenseTimePeriod.all));
        // Other filters should remain
        expect(stateAfterDateClear.searchQuery, equals('test'));
        expect(stateAfterDateClear.minAmount, equals(10.0));
        expect(stateAfterDateClear.maxAmount, equals(100.0));
        expect(stateAfterDateClear.categoryIds, equals([1, 2]));

        // Clear amount filter
        filterNotifier.clearAmountFilter();
        final stateAfterAmountClear = container.read(
          expenseFilterControllerProvider,
        );
        expect(stateAfterAmountClear.minAmount, isNull);
        expect(stateAfterAmountClear.maxAmount, isNull);
        // Other filters should remain
        expect(stateAfterAmountClear.searchQuery, equals('test'));
        expect(stateAfterAmountClear.categoryIds, equals([1, 2]));

        // Clear category filter
        filterNotifier.clearCategoryFilter();
        final stateAfterCategoryClear = container.read(
          expenseFilterControllerProvider,
        );
        expect(stateAfterCategoryClear.categoryIds, isNull);
        // Search should remain
        expect(stateAfterCategoryClear.searchQuery, equals('test'));

        // Clear search query
        filterNotifier.clearSearchQuery();
        final finalState = container.read(expenseFilterControllerProvider);
        expect(finalState.searchQuery, equals(''));
        expect(finalState.hasActiveFilters, isFalse);
      });

      test('should generate filter summary correctly', () {
        final filterNotifier = container.read(
          expenseFilterControllerProvider.notifier,
        );

        // No filters
        final emptyState = container.read(expenseFilterControllerProvider);
        expect(emptyState.filterSummary, equals('No filters applied'));

        // With filters
        filterNotifier.setSearchQuery('coffee');
        filterNotifier.setCategoryFilter([1, 2]);
        filterNotifier.setAmountRange(10.0, 50.0);

        final stateWithFilters = container.read(
          expenseFilterControllerProvider,
        );
        final summary = stateWithFilters.filterSummary;

        expect(summary, contains('2 categories'));
        expect(summary, contains('\$10-\$50'));
        expect(summary, contains('"coffee"'));
      });

      test('should count active filters correctly', () {
        final filterNotifier = container.read(
          expenseFilterControllerProvider.notifier,
        );

        // No filters
        expect(
          container.read(expenseFilterControllerProvider).activeFilterCount,
          equals(0),
        );

        // Add search filter
        filterNotifier.setSearchQuery('test');
        expect(
          container.read(expenseFilterControllerProvider).activeFilterCount,
          equals(1),
        );

        // Add date filter
        filterNotifier.setDateRange(DateTime.now(), DateTime.now());
        expect(
          container.read(expenseFilterControllerProvider).activeFilterCount,
          equals(2),
        );

        // Add amount filter
        filterNotifier.setAmountRange(10.0, 100.0);
        expect(
          container.read(expenseFilterControllerProvider).activeFilterCount,
          equals(3),
        );

        // Add category filter
        filterNotifier.setCategoryFilter([1, 2]);
        expect(
          container.read(expenseFilterControllerProvider).activeFilterCount,
          equals(4),
        );
      });
    });

    group('Quick Amount Options Provider', () {
      test('should provide predefined quick amounts', () {
        final quickAmounts = container.read(quickAmountOptionsProvider);

        expect(quickAmounts, isNotEmpty);
        expect(quickAmounts, contains(5.0));
        expect(quickAmounts, contains(10.0));
        expect(quickAmounts, contains(20.0));
        expect(quickAmounts, contains(50.0));
        expect(quickAmounts, contains(100.0));
      });
    });

    group('Time Period Extensions', () {
      test('should have correct display names', () {
        expect(ExpenseTimePeriod.today.displayName, equals('Today'));
        expect(ExpenseTimePeriod.thisWeek.displayName, equals('This Week'));
        expect(ExpenseTimePeriod.thisMonth.displayName, equals('This Month'));
        expect(ExpenseTimePeriod.thisYear.displayName, equals('This Year'));
        expect(ExpenseTimePeriod.all.displayName, equals('All Time'));
        expect(ExpenseTimePeriod.custom.displayName, equals('Custom Range'));
      });
    });

    group('Filter Preset Extensions', () {
      test('should have correct display names and descriptions', () {
        final preset = ExpenseFilterPreset.largeExpenses;

        expect(preset.displayName, equals('Large Expenses'));
        expect(preset.description, equals('Expenses over \$200'));
      });
    });

    group('Filter Statistics', () {
      test('should calculate percentages correctly', () {
        final stats = ExpenseFilterStats(
          totalExpenses: 100,
          filteredCount: 25,
          filteredTotal: 500.0,
          filteredAverage: 20.0,
          filterEfficiency: 25.0,
        );

        expect(stats.efficiencyPercentage, equals('25.0%'));
        expect(stats.formattedTotal, equals('\$500.00'));
        expect(stats.formattedAverage, equals('\$20.00'));
        expect(stats.resultSummary, equals('Showing 25 of 100 expenses'));
      });

      test('should handle showing all expenses', () {
        final stats = ExpenseFilterStats(
          totalExpenses: 50,
          filteredCount: 50,
          filteredTotal: 1000.0,
          filteredAverage: 20.0,
          filterEfficiency: 100.0,
        );

        expect(stats.resultSummary, equals('Showing all 50 expenses'));
      });
    });
  });
}

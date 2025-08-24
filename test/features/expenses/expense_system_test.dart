import 'package:flutter_test/flutter_test.dart';
import 'package:spendmap2/features/expenses/data/models/expense.dart';
import 'package:spendmap2/features/expenses/domain/entities/expense_entity.dart';
import 'package:spendmap2/features/expenses/domain/use_cases/add_expense_use_case.dart';
import 'package:spendmap2/features/expenses/domain/use_cases/get_expenses_use_case.dart';
import 'package:spendmap2/features/expenses/domain/use_cases/search_expenses_use_case.dart';

void main() {
  group('Expense System Tests', () {
    test('should create expense entity correctly', () {
      final expense = ExpenseEntity(
        id: 1,
        amount: 25.50,
        description: 'Coffee and pastry',
        categoryId: 1,
        date: DateTime.now(),
      );

      expect(expense.id, equals(1));
      expect(expense.amount, equals(25.50));
      expect(expense.description, equals('Coffee and pastry'));
      expect(expense.isValid, isTrue);
      expect(expense.displayDescription, equals('Coffee and pastry'));
    });

    test('should validate expense business rules', () {
      // Valid expense
      final validExpense = ExpenseEntity(
        amount: 25.50,
        description: 'Valid expense',
        categoryId: 1,
        date: DateTime.now(),
      );
      expect(validExpense.validate(), isEmpty);

      // Invalid expense - zero amount
      final invalidExpense = ExpenseEntity(
        amount: 0,
        description: 'Invalid expense',
        categoryId: 1,
        date: DateTime.now(),
      );
      expect(invalidExpense.validate(), isNotEmpty);
      expect(invalidExpense.validate().first, contains('greater than zero'));

      // Invalid expense - negative category
      final invalidCategoryExpense = ExpenseEntity(
        amount: 25.50,
        description: 'Invalid category',
        categoryId: -1,
        date: DateTime.now(),
      );
      expect(invalidCategoryExpense.validate(), isNotEmpty);
    });

    test('should convert between entity and model correctly', () {
      final entity = ExpenseEntity(
        id: 1,
        amount: 25.50,
        description: 'Test expense',
        categoryId: 1,
        date: DateTime.now(),
      );

      // Convert to model
      final model = Expense.fromEntity(entity);
      expect(model.amount, equals(entity.amount));
      expect(model.description, equals(entity.description));
      expect(model.categoryId, equals(entity.categoryId));

      // Convert back to entity
      final convertedEntity = model.toEntity();
      expect(convertedEntity.amount, equals(entity.amount));
      expect(convertedEntity.description, equals(entity.description));
      expect(convertedEntity.categoryId, equals(entity.categoryId));
    });

    test('should handle database conversion correctly', () {
      final expense = Expense(
        id: 1,
        amount: 25.50,
        description: 'Test expense',
        categoryId: 1,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Convert to database map
      final dbMap = expense.toDatabase();
      expect(dbMap['amount'], equals(25.50));
      expect(dbMap['description'], equals('Test expense'));
      expect(dbMap['category_id'], equals(1));
      expect(dbMap['date'], isA<int>());

      // Convert back from database map
      final fromDb = Expense.fromDatabase(dbMap);
      expect(fromDb.amount, equals(25.50));
      expect(fromDb.description, equals('Test expense'));
      expect(fromDb.categoryId, equals(1));
    });

    test('should create expense filter correctly', () {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 30));
      
      final filter = ExpenseFilter(
        startDate: startDate,
        endDate: now,
        categoryIds: [1, 2, 3],
        minAmount: 10.0,
        maxAmount: 100.0,
        searchQuery: 'coffee',
        sortOption: ExpenseSortOption.amountHighest,
      );

      expect(filter.hasActiveFilters, isTrue);
      expect(filter.categoryIds, equals([1, 2, 3]));
      expect(filter.minAmount, equals(10.0));
      expect(filter.searchQuery, equals('coffee'));

      // Test clear filter
      final clearedFilter = filter.clear();
      expect(clearedFilter.hasActiveFilters, isFalse);
      expect(clearedFilter.categoryIds, isNull);
      expect(clearedFilter.searchQuery, isNull);
    });

    test('should create use case params correctly', () {
      // Add expense params
      final addParams = AddExpenseParams(
        amount: 25.50,
        description: 'Coffee',
        categoryId: 1,
        date: DateTime.now(),
      );
      expect(addParams.amount, equals(25.50));
      expect(addParams.description, equals('Coffee'));

      // Get expenses params
      final getParams = GetExpensesParams.thisMonth();
      expect(getParams.type, equals(ExpenseQueryType.thisMonth));

      final dateRangeParams = GetExpensesParams.dateRange(
        DateTime.now().subtract(const Duration(days: 7)),
        DateTime.now(),
      );
      expect(dateRangeParams.type, equals(ExpenseQueryType.dateRange));
      expect(dateRangeParams.startDate, isNotNull);
      expect(dateRangeParams.endDate, isNotNull);

      // Search params
      final searchParams = SearchExpensesParams.simple('coffee');
      expect(searchParams.query, equals('coffee'));
      expect(searchParams.filter, isNull);
    });

    test('should handle expense with category model', () {
      final expenseWithCategory = ExpenseWithCategory(
        id: 1,
        amount: 25.50,
        description: 'Coffee',
        date: DateTime.now(),
        categoryId: 1,
        categoryName: 'Food & Dining',
        categoryIcon: 123,
        categoryColor: 0xFF000000,
      );

      expect(expenseWithCategory.id, equals(1));
      expect(expenseWithCategory.categoryName, equals('Food & Dining'));

      // Convert to expense entity
      final expenseEntity = expenseWithCategory.toExpenseEntity();
      expect(expenseEntity.id, equals(1));
      expect(expenseEntity.amount, equals(25.50));
      expect(expenseEntity.categoryId, equals(1));

      // Get category entity
      final categoryEntity = expenseWithCategory.getCategoryEntity();
      expect(categoryEntity.id, equals(1));
      expect(categoryEntity.name, equals('Food & Dining'));
      expect(categoryEntity.iconCode, equals(123));
    });

    test('should create expense stats correctly', () {
      final stats = ExpenseStats(
        totalAmount: 250.00,
        expenseCount: 10,
        averageAmount: 25.00,
        highestAmount: 50.00,
        lowestAmount: 5.00,
      );

      expect(stats.totalAmount, equals(250.00));
      expect(stats.expenseCount, equals(10));
      expect(stats.isEmpty, isFalse);
      expect(stats.formattedTotal, equals('\$250.00'));
      expect(stats.formattedAverage, equals('\$25.00'));

      // Test empty stats
      final emptyStats = ExpenseStats.empty();
      expect(emptyStats.isEmpty, isTrue);
      expect(emptyStats.totalAmount, equals(0.0));
    });

    test('should handle expense date-based queries correctly', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final todayExpense = ExpenseEntity(
        amount: 25.50,
        description: 'Today expense',
        categoryId: 1,
        date: today.add(const Duration(hours: 12)),
      );

      final yesterdayExpense = ExpenseEntity(
        amount: 30.00,
        description: 'Yesterday expense',
        categoryId: 1,
        date: today.subtract(const Duration(days: 1)),
      );

      expect(todayExpense.isToday, isTrue);
      expect(yesterdayExpense.isToday, isFalse);

      // Test month/year checks
      expect(todayExpense.isThisMonth, isTrue);
      expect(todayExpense.isThisYear, isTrue);

      // Test date key generation
      expect(todayExpense.dateKey, contains('${now.year}'));
      expect(todayExpense.monthYearKey, contains('${now.year}-'));
    });

    test('should handle search query matching correctly', () {
      final expense1 = ExpenseEntity(
        amount: 25.50,
        description: 'Coffee and pastry',
        categoryId: 1,
        date: DateTime.now(),
      );

      final expense2 = ExpenseEntity(
        amount: 15.75,
        description: 'Lunch at restaurant',
        categoryId: 1,
        date: DateTime.now(),
      );

      // Test search matching
      expect(expense1.matchesSearchQuery('coffee'), isTrue);
      expect(expense1.matchesSearchQuery('COFFEE'), isTrue);
      expect(expense1.matchesSearchQuery('pastry'), isTrue);
      expect(expense1.matchesSearchQuery('pizza'), isFalse);

      expect(expense2.matchesSearchQuery('lunch'), isTrue);
      expect(expense2.matchesSearchQuery('restaurant'), isTrue);
      expect(expense2.matchesSearchQuery('15.75'), isTrue);
      expect(expense2.matchesSearchQuery('coffee'), isFalse);

      // Empty query should match all
      expect(expense1.matchesSearchQuery(''), isTrue);
      expect(expense2.matchesSearchQuery(' '), isTrue);
    });

    test('should handle sort options correctly', () {
      expect(ExpenseSortOption.dateNewest.displayName, equals('Date (Newest First)'));
      expect(ExpenseSortOption.amountHighest.displayName, equals('Amount (Highest First)'));
      expect(ExpenseSortOption.description.displayName, equals('Description (A-Z)'));
      
      // Test icons
      expect(ExpenseSortOption.dateNewest.icon, isNotNull);
      expect(ExpenseSortOption.amountHighest.icon, isNotNull);
    });
  });
}
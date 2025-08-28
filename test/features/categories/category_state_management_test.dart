import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spendmap2/features/categories/domain/entities/category_entity.dart';
import 'package:spendmap2/features/categories/presentation/providers/category_form_provider.dart';
import 'package:spendmap2/features/categories/presentation/providers/category_selection_provider.dart';

void main() {
  group('Category State Management Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('Category Form Provider', () {
      test('should initialize with correct default state', () {
        final formState = container.read(categoryFormProvider);

        expect(formState.name, equals(''));
        expect(formState.isEditing, isFalse);
        expect(formState.isDirty, isFalse);
        expect(formState.isSubmitting, isFalse);
        expect(formState.errors, isEmpty);
      });

      test('should update name and mark as dirty', () {
        final formNotifier = container.read(categoryFormProvider.notifier);

        formNotifier.updateName('Food & Dining');

        final formState = container.read(categoryFormProvider);
        expect(formState.name, equals('Food & Dining'));
        expect(formState.isDirty, isTrue);
      });

      test('should validate name correctly', () {
        final formNotifier = container.read(categoryFormProvider.notifier);

        // Empty name should create error
        formNotifier.updateName('');
        final emptyState = container.read(categoryFormProvider);
        expect(emptyState.errors, contains(CategoryFormError.name));

        // Valid name should clear error
        formNotifier.updateName('Valid Category');
        final validState = container.read(categoryFormProvider);
        expect(validState.errors, isNot(contains(CategoryFormError.name)));
      });

      test('should initialize for edit correctly', () {
        final formNotifier = container.read(categoryFormProvider.notifier);
        final category = CategoryEntity(
          id: 1,
          name: 'Test Category',
          iconCode: 123,
          colorValue: 0xFF000000,
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        formNotifier.initializeForEdit(category);

        final formState = container.read(categoryFormProvider);
        expect(formState.id, equals(1));
        expect(formState.name, equals('Test Category'));
        expect(formState.isEditing, isTrue);
        expect(formState.originalCategory, equals(category));
      });

      test('should create category entity from form state', () {
        final formNotifier = container.read(categoryFormProvider.notifier);

        formNotifier.updateName('Test Category');
        formNotifier.updateIcon(456);
        formNotifier.updateColor(0xFF123456);

        final formState = container.read(categoryFormProvider);
        final entity = formState.toEntity();

        expect(entity.name, equals('Test Category'));
        expect(entity.iconCode, equals(456));
        expect(entity.colorValue, equals(0xFF123456));
        expect(entity.isDefault, isFalse);
        expect(entity.isActive, isTrue);
      });

      test('should handle form validation', () {
        final formNotifier = container.read(categoryFormProvider.notifier);

        // Initialize form
        formNotifier.initializeForCreate();

        // Check initial state - should be invalid due to empty name
        var state = container.read(categoryFormProvider);
        expect(state.name, equals(''));
        expect(state.validation.isValid, isFalse);

        // Add valid name
        formNotifier.updateName('Valid Category Name');

        state = container.read(categoryFormProvider);
        expect(state.name, equals('Valid Category Name'));
        expect(state.validation.isValid, isTrue);

        // Add invalid short name
        formNotifier.updateName('A');

        state = container.read(categoryFormProvider);
        expect(state.validation.isValid, isFalse);
        expect(state.errors, isNotEmpty);
      });

      // Add a separate test for async validation
      test('should handle async form validation', () async {
        final formNotifier = container.read(categoryFormProvider.notifier);

        formNotifier.initializeForCreate();
        formNotifier.updateName('Test Category');
        formNotifier.updateIcon(123);
        formNotifier.updateColor(0xFF000000);

        // Run full validation (including async checks)
        final isValid = await formNotifier.validateForm();

        expect(isValid, isTrue);

        final finalState = container.read(categoryFormProvider);
        expect(finalState.errors, isEmpty);
      });
    });

    group('Category Selection Provider', () {
      test('should initialize with empty selection', () {
        final selectionState = container.read(categorySelectionProvider);

        expect(selectionState.hasSelection, isFalse);
        expect(selectionState.selectionCount, equals(0));
        expect(
          selectionState.selectionMode,
          equals(CategorySelectionMode.none),
        );
      });

      test('should handle single category selection', () {
        final selectionNotifier = container.read(
          categorySelectionProvider.notifier,
        );
        final category = CategoryEntity(
          id: 1,
          name: 'Test Category',
          iconCode: 123,
          colorValue: 0xFF000000,
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        selectionNotifier.selectCategory(category);

        final selectionState = container.read(categorySelectionProvider);
        expect(selectionState.hasSelection, isTrue);
        expect(selectionState.selectionCount, equals(1));
        expect(
          selectionState.selectionMode,
          equals(CategorySelectionMode.single),
        );
        expect(selectionState.firstSelected, equals(category));
      });

      test('should handle multiple category selection', () {
        final selectionNotifier = container.read(
          categorySelectionProvider.notifier,
        );
        final category1 = CategoryEntity(
          id: 1,
          name: 'Category 1',
          iconCode: 123,
          colorValue: 0xFF000000,
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        final category2 = CategoryEntity(
          id: 2,
          name: 'Category 2',
          iconCode: 456,
          colorValue: 0xFF111111,
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        selectionNotifier.selectCategories([category1, category2]);

        final selectionState = container.read(categorySelectionProvider);
        expect(selectionState.hasSelection, isTrue);
        expect(selectionState.selectionCount, equals(2));
        expect(
          selectionState.selectionMode,
          equals(CategorySelectionMode.multiple),
        );
      });

      test('should handle category toggle in multi-select', () {
        final selectionNotifier = container.read(
          categorySelectionProvider.notifier,
        );
        final category = CategoryEntity(
          id: 1,
          name: 'Test Category',
          iconCode: 123,
          colorValue: 0xFF000000,
          isDefault: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Toggle to select
        selectionNotifier.toggleCategory(category);

        final selectedState = container.read(categorySelectionProvider);
        expect(selectedState.selectionCount, equals(1));
        expect(selectionNotifier.isCategorySelected(category), isTrue);

        // Toggle to deselect
        selectionNotifier.toggleCategory(category);

        final deselectedState = container.read(categorySelectionProvider);
        expect(deselectedState.selectionCount, equals(0));
        expect(selectionNotifier.isCategorySelected(category), isFalse);
      });

      test('should get selected IDs correctly', () {
        final selectionNotifier = container.read(
          categorySelectionProvider.notifier,
        );
        final categories = [
          CategoryEntity(
            id: 1,
            name: 'Category 1',
            iconCode: 123,
            colorValue: 0xFF000000,
            isDefault: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          CategoryEntity(
            id: 2,
            name: 'Category 2',
            iconCode: 456,
            colorValue: 0xFF111111,
            isDefault: false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        selectionNotifier.selectCategories(categories);

        final selectedIds = selectionNotifier.getSelectedIds();
        expect(selectedIds, equals([1, 2]));
      });
    });

    group('Category Filter Provider', () {
      test('should initialize with default filter state', () {
        final filterState = container.read(categoryFilterProvider);

        expect(filterState.searchQuery, equals(''));
        expect(filterState.showActiveOnly, isTrue);
        expect(filterState.showDefaultOnly, isFalse);
        expect(filterState.showUserCreatedOnly, isFalse);
        expect(filterState.hasActiveFilters, isFalse);
      });

      test('should handle search query updates', () {
        final filterNotifier = container.read(categoryFilterProvider.notifier);

        filterNotifier.setSearchQuery('food');

        final filterState = container.read(categoryFilterProvider);
        expect(filterState.searchQuery, equals('food'));
        expect(filterState.hasActiveFilters, isTrue);
      });

      test('should handle multiple filter updates', () {
        final filterNotifier = container.read(categoryFilterProvider.notifier);

        filterNotifier.applyFilters(
          searchQuery: 'dining',
          showActiveOnly: false,
          showDefaultOnly: true,
        );

        final filterState = container.read(categoryFilterProvider);
        expect(filterState.searchQuery, equals('dining'));
        expect(filterState.showActiveOnly, isFalse);
        expect(filterState.showDefaultOnly, isTrue);
        expect(filterState.hasActiveFilters, isTrue);
      });

      test('should generate filter summary correctly', () {
        final filterNotifier = container.read(categoryFilterProvider.notifier);

        filterNotifier.applyFilters(searchQuery: 'test', showDefaultOnly: true);

        final filterState = container.read(categoryFilterProvider);
        final summary = filterState.filterSummary;

        expect(summary, contains('Search: "test"'));
        expect(summary, contains('Default only'));
      });

      test('should clear filters correctly', () {
        final filterNotifier = container.read(categoryFilterProvider.notifier);

        // Set some filters
        filterNotifier.applyFilters(searchQuery: 'test', showDefaultOnly: true);

        // Clear filters
        filterNotifier.clearFilters();

        final filterState = container.read(categoryFilterProvider);
        expect(filterState.searchQuery, equals(''));
        expect(filterState.showDefaultOnly, isFalse);
        expect(filterState.hasActiveFilters, isFalse);
      });
    });

    group('Category Icon Search Provider', () {
      test('should provide default icons initially', () {
        final iconSearch = container.read(categoryIconSearchProvider);

        expect(iconSearch, isNotEmpty);
        expect(iconSearch.length, greaterThan(5));
        expect(iconSearch.first.name, isNotEmpty);
      });

      test('should filter icons by search query', () {
        final iconSearchNotifier = container.read(
          categoryIconSearchProvider.notifier,
        );

        iconSearchNotifier.search('food');

        final filteredIcons = container.read(categoryIconSearchProvider);
        // Should contain icons with 'food' in name or keywords
        expect(
          filteredIcons.any(
            (icon) =>
                icon.name.toLowerCase().contains('food') ||
                icon.keywords.any(
                  (keyword) => keyword.toLowerCase().contains('food'),
                ),
          ),
          isTrue,
        );
      });

      test('should reset to default icons', () {
        final iconSearchNotifier = container.read(
          categoryIconSearchProvider.notifier,
        );

        // Search first
        iconSearchNotifier.search('car');
        final searchResults = container.read(categoryIconSearchProvider);

        // Reset
        iconSearchNotifier.resetToDefault();
        final resetResults = container.read(categoryIconSearchProvider);

        expect(resetResults.length, greaterThan(searchResults.length));
      });
    });
  });
}

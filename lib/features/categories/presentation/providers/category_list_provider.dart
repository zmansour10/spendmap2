import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/category_entity.dart';
import 'category_provider.dart';
import 'category_selection_provider.dart';

part 'category_list_provider.g.dart';

// Category List View State Provider
@riverpod
class CategoryListState extends _$CategoryListState {
  @override
  CategoryListViewState build() {
    return const CategoryListViewState.initial();
  }

  /// Set view mode (grid/list)
  void setViewMode(CategoryViewMode viewMode) {
    state = state.copyWith(viewMode: viewMode);
  }

  /// Set sort option
  void setSortOption(CategorySortOption sortOption) {
    state = state.copyWith(sortOption: sortOption);
  }

  /// Toggle sort direction
  void toggleSortDirection() {
    state = state.copyWith(sortAscending: !state.sortAscending);
  }

  /// Set edit mode
  void setEditMode(bool editMode) {
    state = state.copyWith(isEditMode: editMode);
    
    // Clear selection when exiting edit mode
    if (!editMode) {
      ref.read(categorySelectionProvider.notifier).clearSelection();
    }
  }

  /// Toggle edit mode
  void toggleEditMode() {
    setEditMode(!state.isEditMode);
  }

  /// Set loading state
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  /// Set error state
  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh view
  void refresh() {
    state = state.copyWith(
      isLoading: false,
      error: null,
    );
    
    // Invalidate category data to force refresh
    ref.invalidate(categoriesProvider);
  }
}

// Sorted Categories Provider (applies current sort settings)
@riverpod
Future<List<CategoryEntity>> sortedCategories(ref) async {
  final listState = ref.watch(categoryListStateProvider);
  final categories = await ref.watch(filteredCategoriesProvider.future);

  // Apply sorting
  final sortedList = List<CategoryEntity>.from(categories);
  
  switch (listState.sortOption) {
    case CategorySortOption.name:
      sortedList.sort((a, b) => a.name.compareTo(b.name));
      break;
    case CategorySortOption.createdDate:
      sortedList.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.now();
        final bDate = b.createdAt ?? DateTime.now();
        return aDate.compareTo(bDate);
      });
      break;
    case CategorySortOption.usage:
      // Sort by usage would require expense data - simplified for now
      sortedList.sort((a, b) => a.name.compareTo(b.name));
      break;
    case CategorySortOption.type:
      sortedList.sort((a, b) {
        // Sort by type (default first, then user-created)
        if (a.isDefault && !b.isDefault) return -1;
        if (!a.isDefault && b.isDefault) return 1;
        return a.name.compareTo(b.name);
      });
      break;
  }

  // Apply sort direction
  if (!listState.sortAscending) {
    return sortedList.reversed.toList();
  }

  return sortedList;
}

// Category List Actions Provider
@riverpod
class CategoryListActions extends _$CategoryListActions {
  @override
  Future<CategoryActionResult?> build() async {
    return null; // No initial action
  }

  /// Delete selected categories
  Future<CategoryActionResult> deleteSelectedCategories() async {
    final selectedCategories = ref.read(categorySelectionProvider).selectedCategories;
    
    if (selectedCategories.isEmpty) {
      return CategoryActionResult.error('No categories selected');
    }

    state = const AsyncValue.loading();

    try {
      final categoriesNotifier = ref.read(categoriesProvider.notifier);
      final selectedIds = selectedCategories
          .where((cat) => cat.id != null && !cat.isDefault)
          .map((cat) => cat.id!)
          .toList();

      if (selectedIds.isEmpty) {
        return CategoryActionResult.error('Cannot delete default categories');
      }

      await categoriesNotifier.bulkDeleteCategories(selectedIds);
      
      // Clear selection and exit edit mode
      ref.read(categorySelectionProvider.notifier).clearSelection();
      ref.read(categoryListStateProvider.notifier).setEditMode(false);

      final result = CategoryActionResult.success(
        '${selectedIds.length} ${selectedIds.length == 1 ? 'category' : 'categories'} deleted'
      );
      state = AsyncValue.data(result);
      return result;
    } catch (e) {
      final result = CategoryActionResult.error('Failed to delete categories: $e');
      state = AsyncValue.data(result);
      return result;
    }
  }

  /// Restore selected categories
  Future<CategoryActionResult> restoreSelectedCategories() async {
    final selectedCategories = ref.read(categorySelectionProvider).selectedCategories;
    
    if (selectedCategories.isEmpty) {
      return CategoryActionResult.error('No categories selected');
    }

    state = const AsyncValue.loading();

    try {
      final categoriesNotifier = ref.read(categoriesProvider.notifier);
      int restoredCount = 0;

      for (final category in selectedCategories) {
        if (category.id != null && !category.isActive) {
          await categoriesNotifier.restoreCategory(category.id!);
          restoredCount++;
        }
      }

      if (restoredCount == 0) {
        return CategoryActionResult.error('No inactive categories to restore');
      }

      // Clear selection
      ref.read(categorySelectionProvider.notifier).clearSelection();

      final result = CategoryActionResult.success(
        '$restoredCount ${restoredCount == 1 ? 'category' : 'categories'} restored'
      );
      state = AsyncValue.data(result);
      return result;
    } catch (e) {
      final result = CategoryActionResult.error('Failed to restore categories: $e');
      state = AsyncValue.data(result);
      return result;
    }
  }

  /// Duplicate selected category
  Future<CategoryActionResult> duplicateCategory(CategoryEntity category) async {
    state = const AsyncValue.loading();

    try {
      final newCategory = CategoryEntity(
        name: '${category.name} (Copy)',
        iconCode: category.iconCode,
        colorValue: category.colorValue,
        isDefault: false,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final categoriesNotifier = ref.read(categoriesProvider.notifier);
      await categoriesNotifier.addCategory(newCategory);

      final result = CategoryActionResult.success('Category duplicated');
      state = AsyncValue.data(result);
      return result;
    } catch (e) {
      final result = CategoryActionResult.error('Failed to duplicate category: $e');
      state = AsyncValue.data(result);
      return result;
    }
  }

  /// Clear action result
  void clearResult() {
    state = const AsyncValue.data(null);
  }
}

// Category Statistics for List View
@riverpod
Future<CategoryListStats> categoryListStats(ref) async {
  final allCategories = await ref.watch(categoriesProvider.future);
  final filteredCategories = await ref.watch(filteredCategoriesProvider.future);
  final selection = ref.watch(categorySelectionProvider);

  final activeCount = allCategories.where((cat) => cat.isActive).length;
  final inactiveCount = allCategories.length - activeCount;
  final defaultCount = allCategories.where((cat) => cat.isDefault).length;
  final userCreatedCount = allCategories.length - defaultCount;

  return CategoryListStats(
    totalCategories: allCategories.length,
    filteredCount: filteredCategories.length,
    activeCount: activeCount,
    inactiveCount: inactiveCount,
    defaultCount: defaultCount,
    userCreatedCount: userCreatedCount,
    selectedCount: selection.selectionCount,
  );
}

/// Category list view state
class CategoryListViewState {
  final CategoryViewMode viewMode;
  final CategorySortOption sortOption;
  final bool sortAscending;
  final bool isEditMode;
  final bool isLoading;
  final String? error;

  const CategoryListViewState({
    required this.viewMode,
    required this.sortOption,
    required this.sortAscending,
    required this.isEditMode,
    required this.isLoading,
    this.error,
  });

  const CategoryListViewState.initial() : this(
    viewMode: CategoryViewMode.list,
    sortOption: CategorySortOption.name,
    sortAscending: true,
    isEditMode: false,
    isLoading: false,
  );

  CategoryListViewState copyWith({
    CategoryViewMode? viewMode,
    CategorySortOption? sortOption,
    bool? sortAscending,
    bool? isEditMode,
    bool? isLoading,
    String? error,
  }) {
    return CategoryListViewState(
      viewMode: viewMode ?? this.viewMode,
      sortOption: sortOption ?? this.sortOption,
      sortAscending: sortAscending ?? this.sortAscending,
      isEditMode: isEditMode ?? this.isEditMode,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  String toString() {
    return 'CategoryListViewState(viewMode: $viewMode, sort: $sortOption, editMode: $isEditMode)';
  }
}

/// Category view modes
enum CategoryViewMode {
  list,
  grid,
}

/// Category sort options
enum CategorySortOption {
  name,
  createdDate,
  usage,
  type,
}

extension CategorySortOptionExtension on CategorySortOption {
  String get displayName {
    switch (this) {
      case CategorySortOption.name:
        return 'Name';
      case CategorySortOption.createdDate:
        return 'Date Created';
      case CategorySortOption.usage:
        return 'Usage';
      case CategorySortOption.type:
        return 'Type';
    }
  }
}

/// Category action result
class CategoryActionResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  const CategoryActionResult._({
    required this.isSuccess,
    required this.message,
    this.data,
  });

  factory CategoryActionResult.success(String message, {dynamic data}) {
    return CategoryActionResult._(
      isSuccess: true,
      message: message,
      data: data,
    );
  }

  factory CategoryActionResult.error(String message) {
    return CategoryActionResult._(
      isSuccess: false,
      message: message,
    );
  }
}

/// Category list statistics
class CategoryListStats {
  final int totalCategories;
  final int filteredCount;
  final int activeCount;
  final int inactiveCount;
  final int defaultCount;
  final int userCreatedCount;
  final int selectedCount;

  const CategoryListStats({
    required this.totalCategories,
    required this.filteredCount,
    required this.activeCount,
    required this.inactiveCount,
    required this.defaultCount,
    required this.userCreatedCount,
    required this.selectedCount,
  });

  /// Get filter summary
  String get filterSummary {
    if (filteredCount == totalCategories) {
      return '$totalCategories categories';
    }
    return '$filteredCount of $totalCategories categories';
  }

  /// Get selection summary
  String get selectionSummary {
    if (selectedCount == 0) {
      return 'None selected';
    }
    return '$selectedCount selected';
  }
}
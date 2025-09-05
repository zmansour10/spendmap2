import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/category_entity.dart';
import 'category_provider.dart';

part 'category_selection_provider.g.dart';

// Category Selection Provider (for forms and filters)
@riverpod
class CategorySelection extends _$CategorySelection {
  @override
  CategorySelectionState build() {
    return const CategorySelectionState.initial();
  }

  /// Select a single category
  void selectCategory(CategoryEntity category) {
    state = CategorySelectionState.single(category);
  }

  /// Select multiple categories
  void selectCategories(List<CategoryEntity> categories) {
    state = CategorySelectionState.multiple(categories);
  }

  /// Toggle category selection (for multi-select)
  void toggleCategory(CategoryEntity category) {
    final currentSelected = state.selectedCategories;
    final isSelected = currentSelected.any((cat) => cat.id == category.id);
    
    List<CategoryEntity> newSelected;
    if (isSelected) {
      newSelected = currentSelected.where((cat) => cat.id != category.id).toList();
    } else {
      newSelected = [...currentSelected, category];
    }

    state = CategorySelectionState.multiple(newSelected);
  }

  /// Clear selection
  void clearSelection() {
    state = const CategorySelectionState.initial();
  }

  /// Check if category is selected
  bool isCategorySelected(CategoryEntity category) {
    return state.selectedCategories.any((cat) => cat.id == category.id);
  }

  /// Get selected category IDs
  List<int> getSelectedIds() {
    return state.selectedCategories
        .where((cat) => cat.id != null)
        .map((cat) => cat.id!)
        .toList();
  }

  /// Set selection mode
  void setMultiSelectMode(bool multiSelect) {
    if (multiSelect && state.selectionMode == CategorySelectionMode.single) {
      // Convert single selection to multi-select
      state = CategorySelectionState.multiple(state.selectedCategories);
    } else if (!multiSelect && state.selectionMode == CategorySelectionMode.multiple) {
      // Convert to single selection (keep first item)
      final firstCategory = state.selectedCategories.isNotEmpty 
          ? state.selectedCategories.first 
          : null;
      state = firstCategory != null 
          ? CategorySelectionState.single(firstCategory)
          : const CategorySelectionState.initial();
    }
  }
}

// Category Filter Provider (for search and filtering)
@riverpod
class CategoryFilter extends _$CategoryFilter {
  @override
  CategoryFilterState build() {
    return const CategoryFilterState.initial();
  }

  /// Set search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  /// Set active filter
  void setShowActiveOnly(bool showActiveOnly) {
    state = state.copyWith(showActiveOnly: showActiveOnly);
  }

  /// Set default filter
  void setShowDefaultOnly(bool showDefaultOnly) {
    state = state.copyWith(showDefaultOnly: showDefaultOnly);
  }

  /// Set user-created filter
  void setShowUserCreatedOnly(bool showUserCreatedOnly) {
    state = state.copyWith(showUserCreatedOnly: showUserCreatedOnly);
  }

  /// Clear all filters
  void clearFilters() {
    state = const CategoryFilterState.initial();
  }

  /// Apply multiple filters at once
  void applyFilters({
    String? searchQuery,
    bool? showActiveOnly,
    bool? showDefaultOnly,
    bool? showUserCreatedOnly,
  }) {
    state = state.copyWith(
      searchQuery: searchQuery ?? state.searchQuery,
      showActiveOnly: showActiveOnly ?? state.showActiveOnly,
      showDefaultOnly: showDefaultOnly ?? state.showDefaultOnly,
      showUserCreatedOnly: showUserCreatedOnly ?? state.showUserCreatedOnly,
    );
  }
}

// Filtered Categories Provider (based on current filters)
@riverpod
Future<List<CategoryEntity>> filteredCategories(ref) async {
  final filter = ref.watch(categoryFilterProvider);
  final repository = ref.watch(categoryRepositoryProvider);

  // Start with appropriate base list
  List<CategoryEntity> categories;
  
  if (filter.showDefaultOnly && filter.showUserCreatedOnly) {
    // Show all categories
    categories = await repository.getAllCategories();
  } else if (filter.showDefaultOnly) {
    categories = await repository.getDefaultCategories();
  } else if (filter.showUserCreatedOnly) {
    categories = await repository.getUserCategories();
  } else {
    categories = await repository.getAllCategories();
  }

  // Apply active filter
  if (filter.showActiveOnly) {
    categories = categories.where((cat) => cat.isActive).toList();
  }

  // Apply search filter
  if (filter.searchQuery.isNotEmpty) {
    final query = filter.searchQuery.toLowerCase();
    categories = categories.where((cat) => 
        cat.name.toLowerCase().contains(query)
    ).toList();
  }

  return categories;
}

/// Category selection state
class CategorySelectionState {
  final List<CategoryEntity> selectedCategories;
  final CategorySelectionMode selectionMode;

  const CategorySelectionState({
    required this.selectedCategories,
    required this.selectionMode,
  });

  const CategorySelectionState.initial() : this(
    selectedCategories: const [],
    selectionMode: CategorySelectionMode.none,
  );

  factory CategorySelectionState.single(CategoryEntity category) {
    return CategorySelectionState(
      selectedCategories: [category],
      selectionMode: CategorySelectionMode.single,
    );
  }

  factory CategorySelectionState.multiple(List<CategoryEntity> categories) {
    return CategorySelectionState(
      selectedCategories: categories,
      selectionMode: categories.isEmpty 
          ? CategorySelectionMode.none 
          : CategorySelectionMode.multiple,
    );
  }

  CategorySelectionState copyWith({
    List<CategoryEntity>? selectedCategories,
    CategorySelectionMode? selectionMode,
  }) {
    return CategorySelectionState(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectionMode: selectionMode ?? this.selectionMode,
    );
  }

  // Helper getters
 bool get hasSelection => selectedCategories.isNotEmpty;
 
 int get selectionCount => selectedCategories.length;
 
 CategoryEntity? get firstSelected => 
     selectedCategories.isNotEmpty ? selectedCategories.first : null;
 
 bool get isSingleSelection => selectionMode == CategorySelectionMode.single;
 
 bool get isMultiSelection => selectionMode == CategorySelectionMode.multiple;
 
 @override
 String toString() {
   return 'CategorySelectionState(count: ${selectedCategories.length}, mode: $selectionMode)';
 }
}

/// Category filter state
class CategoryFilterState {
 final String searchQuery;
 final bool showActiveOnly;
 final bool showDefaultOnly;
 final bool showUserCreatedOnly;

 const CategoryFilterState({
   required this.searchQuery,
   required this.showActiveOnly,
   required this.showDefaultOnly,
   required this.showUserCreatedOnly,
 });

 const CategoryFilterState.initial() : this(
   searchQuery: '',
   showActiveOnly: true,
   showDefaultOnly: false,
   showUserCreatedOnly: false,
 );

 CategoryFilterState copyWith({
   String? searchQuery,
   bool? showActiveOnly,
   bool? showDefaultOnly,
   bool? showUserCreatedOnly,
 }) {
   return CategoryFilterState(
     searchQuery: searchQuery ?? this.searchQuery,
     showActiveOnly: showActiveOnly ?? this.showActiveOnly,
     showDefaultOnly: showDefaultOnly ?? this.showDefaultOnly,
     showUserCreatedOnly: showUserCreatedOnly ?? this.showUserCreatedOnly,
   );
 }

 /// Check if any filters are active
 bool get hasActiveFilters {
   return searchQuery.isNotEmpty ||
          !showActiveOnly ||
          showDefaultOnly ||
          showUserCreatedOnly;
 }

 /// Get filter summary for display
 String get filterSummary {
   final filters = <String>[];
   
   if (searchQuery.isNotEmpty) {
     filters.add('Search: "$searchQuery"');
   }
   if (!showActiveOnly) {
     filters.add('Including inactive');
   }
   if (showDefaultOnly) {
     filters.add('Default only');
   }
   if (showUserCreatedOnly) {
     filters.add('User-created only');
   }

   return filters.isEmpty ? 'No filters' : filters.join(', ');
 }

 @override
 String toString() {
   return 'CategoryFilterState(query: "$searchQuery", activeOnly: $showActiveOnly, defaultOnly: $showDefaultOnly, userOnly: $showUserCreatedOnly)';
 }
}

/// Selection modes
enum CategorySelectionMode {
 none,
 single,
 multiple,
}
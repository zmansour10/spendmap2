import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../data/data_sources/category_local_data_source.dart';
import '../../../shared/providers/database_provider.dart';
import 'package:spendmap2/features/categories/presentation/providers/category_form_provider.dart';

part 'category_provider.g.dart';

// Category Repository Provider
@riverpod
CategoryRepository categoryRepository(CategoryRepositoryRef ref) {
  final databaseHelper = ref.watch(databaseHelperProvider);
  final dataSource = CategoryLocalDataSource(databaseHelper);
  return CategoryRepositoryImpl(dataSource);
}

// All Categories Provider (includes inactive)
@riverpod
class Categories extends _$Categories {
  @override
  Future<List<CategoryEntity>> build() async {
    final repository = ref.watch(categoryRepositoryProvider);
    return await repository.getAllCategories();
  }

  /// Refresh categories
  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// Add a new category
  Future<CategoryEntity> addCategory(CategoryEntity category) async {
    final repository = ref.watch(categoryRepositoryProvider);
    
    try {
      final newCategory = await repository.createCategory(category);
      
      // Refresh the list to include the new category
      ref.invalidateSelf();
      
      return newCategory;
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing category
  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    final repository = ref.watch(categoryRepositoryProvider);
    
    try {
      final updatedCategory = await repository.updateCategory(category);
      
      // Update the local state optimistically
      final currentState = state.valueOrNull ?? [];
      final updatedList = currentState.map((cat) {
        return cat.id == category.id ? updatedCategory : cat;
      }).toList();
      
      state = AsyncValue.data(updatedList);
      
      return updatedCategory;
    } catch (e) {
      // Refresh on error to get correct state
      ref.invalidateSelf();
      rethrow;
    }
  }

  /// Delete a category (soft delete)
  Future<void> deleteCategory(int categoryId) async {
    final repository = ref.watch(categoryRepositoryProvider);
    
    try {
      await repository.deleteCategory(categoryId);
      
      // Remove from local state optimistically
      final currentState = state.valueOrNull ?? [];
      final updatedList = currentState.where((cat) => cat.id != categoryId).toList();
      state = AsyncValue.data(updatedList);
    } catch (e) {
      // Refresh on error
      ref.invalidateSelf();
      rethrow;
    }
  }

  /// Restore a deleted category
  Future<CategoryEntity> restoreCategory(int categoryId) async {
    final repository = ref.watch(categoryRepositoryProvider);
    
    try {
      final restoredCategory = await repository.restoreCategory(categoryId);
      
      // Refresh to get updated state
      ref.invalidateSelf();
      
      return restoredCategory;
    } catch (e) {
      rethrow;
    }
  }

  /// Bulk delete categories
  Future<void> bulkDeleteCategories(List<int> categoryIds) async {
    final repository = ref.watch(categoryRepositoryProvider);
    
    try {
      await repository.bulkDeleteCategories(categoryIds);
      
      // Remove from local state
      final currentState = state.valueOrNull ?? [];
      final updatedList = currentState
          .where((cat) => !categoryIds.contains(cat.id))
          .toList();
      state = AsyncValue.data(updatedList);
    } catch (e) {
      ref.invalidateSelf();
      rethrow;
    }
  }

  /// Reset to default categories
  Future<void> resetToDefaults() async {
    final repository = ref.watch(categoryRepositoryProvider);
    
    try {
      await repository.resetToDefaultCategories();
      ref.invalidateSelf();
    } catch (e) {
      rethrow;
    }
  }
}

// Active Categories Provider (most commonly used)
@riverpod
Future<List<CategoryEntity>> activeCategories(ActiveCategoriesRef ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getActiveCategories();
}

// Default Categories Provider
@riverpod
Future<List<CategoryEntity>> defaultCategories(DefaultCategoriesRef ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getDefaultCategories();
}

// User Categories Provider
@riverpod
Future<List<CategoryEntity>> userCategories(UserCategoriesRef ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getUserCategories();
}

// Inactive Categories Provider
@riverpod
Future<List<CategoryEntity>> inactiveCategories(InactiveCategoriesRef ref) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getInactiveCategories();
}

// Category by ID Provider (Family)
@riverpod
Future<CategoryEntity?> categoryById(CategoryByIdRef ref, int categoryId) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getCategoryById(categoryId);
}

// Category by Name Provider (Family)
@riverpod
Future<CategoryEntity?> categoryByName(CategoryByNameRef ref, String categoryName) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getCategoryByName(categoryName);
}

// Search Categories Provider (Family)
@riverpod
Future<List<CategoryEntity>> searchCategories(SearchCategoriesRef ref, String query) async {
  final repository = ref.watch(categoryRepositoryProvider);
  if (query.trim().isEmpty) {
    return await repository.getActiveCategories();
  }
  return await repository.searchCategories(query);
}

// Category Count Provider
@riverpod
Future<int> categoryCount(CategoryCountRef ref, {bool includeInactive = false}) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.getCategoriesCount(includeInactive: includeInactive);
}

// Category Name Exists Provider (Family)
@riverpod
Future<bool> categoryNameExists(CategoryNameExistsRef ref, String categoryName, {int? excludeId}) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.categoryNameExists(categoryName, excludeId: excludeId);
}

// Category Has Expenses Provider (Family)
@riverpod
Future<bool> categoryHasExpenses(CategoryHasExpensesRef ref, int categoryId) async {
  final repository = ref.watch(categoryRepositoryProvider);
  return await repository.categoryHasExpenses(categoryId);
}

// Category Statistics Provider
@riverpod
class CategoryStatistics extends _$CategoryStatistics {
  @override
  Future<CategoryStats> build() async {
    final repository = ref.watch(categoryRepositoryProvider);
    
    final totalCount = await repository.getCategoriesCount();
    final activeCount = await repository.getCategoriesCount(includeInactive: false);
    final userCount = (await repository.getUserCategories()).length;
    final defaultCount = (await repository.getDefaultCategories()).length;
    
    return CategoryStats(
      totalCount: totalCount,
      activeCount: activeCount,
      inactiveCount: totalCount - activeCount,
      userCreatedCount: userCount,
      defaultCount: defaultCount,
    );
  }

  /// Refresh statistics
  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

// Category Management Operations Provider
@riverpod
class CategoryOperations extends _$CategoryOperations {
  @override
  Future<CategoryOperationResult?> build() async {
    return null; // No initial operation
  }

  /// Create default categories if they don't exist
  Future<CategoryOperationResult> createDefaultCategories() async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.watch(categoryRepositoryProvider);
      await repository.createDefaultCategories();
      
      // Refresh all category lists
      ref.invalidate(categoriesProvider);
      ref.invalidate(activeCategoriesProvider);
      ref.invalidate(defaultCategoriesProvider);
      
      final result = CategoryOperationResult.success('Default categories created or already exist');
      state = AsyncValue.data(result);
      return result;
    } catch (e) {
      final result = CategoryOperationResult.error('Failed to create default categories: $e');
      state = AsyncValue.data(result);
      return result;
    }
  }

  /// Bulk create categories
  Future<CategoryOperationResult> bulkCreateCategories(List<CategoryEntity> categories) async {
    state = const AsyncValue.loading();
    
    try {
      final repository = ref.watch(categoryRepositoryProvider);
      final createdCategories = await repository.bulkCreateCategories(categories);
      
      // Refresh category lists
      ref.invalidate(categoriesProvider);
      ref.invalidate(activeCategoriesProvider);
      
      final result = CategoryOperationResult.success(
        'Successfully created ${createdCategories.length} categories',
        data: createdCategories,
      );
      state = AsyncValue.data(result);
      return result;
    } catch (e) {
      final result = CategoryOperationResult.error('Failed to create categories: $e');
      state = AsyncValue.data(result);
      return result;
    }
  }

  /// Clear operation result
  void clearResult() {
    state = const AsyncValue.data(null);
  }
}
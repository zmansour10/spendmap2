import '../entities/category_entity.dart';

/// Abstract repository interface defining category operations
/// This belongs to domain layer - no implementation details
abstract class CategoryRepository {
  /// Get all active categories
  Future<List<CategoryEntity>> getAllCategories();
  
  /// Get active categories only
  Future<List<CategoryEntity>> getActiveCategories();
  
  /// Get inactive categories only
  Future<List<CategoryEntity>> getInactiveCategories();
  
  /// Get default (system) categories
  Future<List<CategoryEntity>> getDefaultCategories();
  
  /// Get user-created categories
  Future<List<CategoryEntity>> getUserCategories();
  
  /// Get category by ID
  Future<CategoryEntity?> getCategoryById(int id);
  
  /// Get category by name
  Future<CategoryEntity?> getCategoryByName(String name);
  
  /// Search categories by name
  Future<List<CategoryEntity>> searchCategories(String query);
  
  /// Create new category
  Future<CategoryEntity> createCategory(CategoryEntity category);
  
  /// Update existing category
  Future<CategoryEntity> updateCategory(CategoryEntity category);
  
  /// Soft delete category (set inactive)
  Future<void> deleteCategory(int id);
  
  /// Hard delete category (permanent)
  Future<void> permanentlyDeleteCategory(int id);
  
  /// Restore deleted category
  Future<CategoryEntity> restoreCategory(int id);
  
  /// Check if category name exists
  Future<bool> categoryNameExists(String name, {int? excludeId});
  
  /// Check if category has expenses
  Future<bool> categoryHasExpenses(int id);
  
  /// Get categories count
  Future<int> getCategoriesCount({bool includeInactive = false});
  
  /// Bulk operations
  Future<void> createDefaultCategories();
  Future<List<CategoryEntity>> bulkCreateCategories(List<CategoryEntity> categories);
  Future<void> bulkUpdateCategories(List<CategoryEntity> categories);
  Future<void> bulkDeleteCategories(List<int> ids);
  
  /// Reset to default categories (for settings)
  Future<void> resetToDefaultCategories();
}
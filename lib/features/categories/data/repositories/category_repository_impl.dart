import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../data_sources/category_local_data_source.dart';
import '../models/category.dart';

/// Implementation of CategoryRepository using local data source
/// Converts between domain entities and data models
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _localDataSource;

  const CategoryRepositoryImpl(this._localDataSource);

  @override
  Future<List<CategoryEntity>> getAllCategories() async {
    try {
      final categories = await _localDataSource.getAllCategories();
      return categories.map((category) => category.toEntity()).toList();
    } catch (e) {
      throw CategoryRepositoryException('Failed to get all categories', e);
    }
  }

  @override
  Future<List<CategoryEntity>> getActiveCategories() async {
    try {
      final categories = await _localDataSource.getActiveCategories();
      return categories.map((category) => category.toEntity()).toList();
    } catch (e) {
      throw CategoryRepositoryException('Failed to get active categories', e);
    }
  }

  @override
  Future<List<CategoryEntity>> getInactiveCategories() async {
    try {
      final categories = await _localDataSource.getInactiveCategories();
      return categories.map((category) => category.toEntity()).toList();
    } catch (e) {
      throw CategoryRepositoryException('Failed to get inactive categories', e);
    }
  }

  @override
  Future<List<CategoryEntity>> getDefaultCategories() async {
    try {
      final categories = await _localDataSource.getDefaultCategories();
      return categories.map((category) => category.toEntity()).toList();
    } catch (e) {
      throw CategoryRepositoryException('Failed to get default categories', e);
    }
  }

  @override
  Future<List<CategoryEntity>> getUserCategories() async {
    try {
      final categories = await _localDataSource.getUserCategories();
      return categories.map((category) => category.toEntity()).toList();
    } catch (e) {
      throw CategoryRepositoryException('Failed to get user categories', e);
    }
  }

  @override
  Future<CategoryEntity?> getCategoryById(int id) async {
    try {
      final category = await _localDataSource.getCategoryById(id);
      return category?.toEntity();
    } catch (e) {
      throw CategoryRepositoryException('Failed to get category by ID', e);
    }
  }

  @override
  Future<CategoryEntity?> getCategoryByName(String name) async {
    try {
      final category = await _localDataSource.getCategoryByName(name);
      return category?.toEntity();
    } catch (e) {
      throw CategoryRepositoryException('Failed to get category by name', e);
    }
  }

  @override
  Future<List<CategoryEntity>> searchCategories(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getActiveCategories();
      }
      
      final categories = await _localDataSource.searchCategories(query);
      return categories.map((category) => category.toEntity()).toList();
    } catch (e) {
      throw CategoryRepositoryException('Failed to search categories', e);
    }
  }

  @override
  Future<CategoryEntity> createCategory(CategoryEntity category) async {
    try {
      // Validate category data
      _validateCategory(category);
      
      // Check if name already exists
      final nameExists = await _localDataSource.categoryNameExists(category.name);
      if (nameExists) {
        throw CategoryRepositoryException('Category with this name already exists', null);
      }

      // Convert to data model and insert
      final categoryModel = Category.fromEntity(category).copyWith(
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      final insertedCategory = await _localDataSource.insertCategory(categoryModel);
      return insertedCategory.toEntity();
    } catch (e) {
      if (e is CategoryRepositoryException) rethrow;
      throw CategoryRepositoryException('Failed to create category', e);
    }
  }

  @override
  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    try {
      if (category.id == null) {
        throw CategoryRepositoryException('Cannot update category without ID', null);
      }

      // Validate category data
      _validateCategory(category);

      // Check if category exists
      final existingCategory = await _localDataSource.getCategoryById(category.id!);
      if (existingCategory == null) {
        throw CategoryRepositoryException('Category not found for update', null);
      }

      // Check if trying to update default category inappropriately
      if (existingCategory.isDefault && !category.isDefault) {
        throw CategoryRepositoryException('Cannot change default category to user category', null);
      }

      // Check if name already exists (excluding current category)
      final nameExists = await _localDataSource.categoryNameExists(
        category.name, 
        excludeId: category.id,
      );
      if (nameExists) {
        throw CategoryRepositoryException('Category with this name already exists', null);
      }

      // Convert to data model and update
      final categoryModel = Category.fromEntity(category);
      final updatedCategory = await _localDataSource.updateCategory(categoryModel);
      return updatedCategory.toEntity();
    } catch (e) {
      if (e is CategoryRepositoryException) rethrow;
      throw CategoryRepositoryException('Failed to update category', e);
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      // Check if category exists and can be deleted
      final category = await _localDataSource.getCategoryById(id);
      if (category == null) {
        throw CategoryRepositoryException('Category not found for deletion', null);
      }

      if (category.isDefault) {
        throw CategoryRepositoryException('Cannot delete default category', null);
      }

      // Check if category has expenses
      final hasExpenses = await _localDataSource.categoryHasExpenses(id);
      if (hasExpenses) {
        // Soft delete only
        await _localDataSource.deleteCategory(id);
      } else {
        // Can hard delete if no expenses
        await _localDataSource.permanentlyDeleteCategory(id);
      }
    } catch (e) {
      if (e is CategoryRepositoryException) rethrow;
      throw CategoryRepositoryException('Failed to delete category', e);
    }
  }

  @override
  Future<void> permanentlyDeleteCategory(int id) async {
    try {
      // Check if category exists
      final category = await _localDataSource.getCategoryById(id);
      if (category == null) {
       throw CategoryRepositoryException('Category not found for permanent deletion', null);
     }

     if (category.isDefault) {
       throw CategoryRepositoryException('Cannot permanently delete default category', null);
     }

     // Check if category has expenses
     final hasExpenses = await _localDataSource.categoryHasExpenses(id);
     if (hasExpenses) {
       throw CategoryRepositoryException('Cannot permanently delete category with expenses', null);
     }

     await _localDataSource.permanentlyDeleteCategory(id);
   } catch (e) {
     if (e is CategoryRepositoryException) rethrow;
     throw CategoryRepositoryException('Failed to permanently delete category', e);
   }
 }

 @override
 Future<CategoryEntity> restoreCategory(int id) async {
   try {
     // Check if category exists and is inactive
     final category = await _localDataSource.getCategoryById(id);
     if (category == null) {
       throw CategoryRepositoryException('Category not found for restoration', null);
     }

     if (category.isActive) {
       throw CategoryRepositoryException('Category is already active', null);
     }

     // Check if name conflicts with existing active category
     final nameExists = await _localDataSource.categoryNameExists(
       category.name, 
       excludeId: id,
     );
     if (nameExists) {
       throw CategoryRepositoryException(
         'Cannot restore: Category with this name already exists', 
         null,
       );
     }

     final restoredCategory = await _localDataSource.restoreCategory(id);
     return restoredCategory.toEntity();
   } catch (e) {
     if (e is CategoryRepositoryException) rethrow;
     throw CategoryRepositoryException('Failed to restore category', e);
   }
 }

 @override
 Future<bool> categoryNameExists(String name, {int? excludeId}) async {
   try {
     return await _localDataSource.categoryNameExists(name, excludeId: excludeId);
   } catch (e) {
     throw CategoryRepositoryException('Failed to check if category name exists', e);
   }
 }

 @override
 Future<bool> categoryHasExpenses(int id) async {
   try {
     return await _localDataSource.categoryHasExpenses(id);
   } catch (e) {
     throw CategoryRepositoryException('Failed to check if category has expenses', e);
   }
 }

 @override
 Future<int> getCategoriesCount({bool includeInactive = false}) async {
   try {
     return await _localDataSource.getCategoriesCount(includeInactive: includeInactive);
   } catch (e) {
     throw CategoryRepositoryException('Failed to get categories count', e);
   }
 }

 @override
 Future<void> createDefaultCategories() async {
   try {
     // Get existing default categories to avoid duplicates
     final existingDefaults = await _localDataSource.getDefaultCategories();
     final existingNames = existingDefaults.map((c) => c.name.toLowerCase()).toSet();

     // Create categories from templates that don't already exist
     final categoriesToCreate = CategoryTemplates.templates
         .where((template) => !existingNames.contains(template.name.toLowerCase()))
         .map((template) => CategoryTemplates.createFromTemplate(template, isDefault: true))
         .toList();

     if (categoriesToCreate.isNotEmpty) {
       await _localDataSource.bulkInsertCategories(categoriesToCreate);
     }
   } catch (e) {
     throw CategoryRepositoryException('Failed to create default categories', e);
   }
 }

 @override
 Future<List<CategoryEntity>> bulkCreateCategories(List<CategoryEntity> categories) async {
   try {
     // Validate all categories
     for (final category in categories) {
       _validateCategory(category);
     }

     // Check for duplicate names within the batch
     final names = categories.map((c) => c.name.toLowerCase()).toList();
     final uniqueNames = names.toSet();
     if (names.length != uniqueNames.length) {
       throw CategoryRepositoryException('Duplicate category names in batch', null);
     }

     // Check for existing names in database
     for (final category in categories) {
       final nameExists = await _localDataSource.categoryNameExists(category.name);
       if (nameExists) {
         throw CategoryRepositoryException('Category "${category.name}" already exists', null);
       }
     }

     // Convert to data models with timestamps
     final categoryModels = categories
         .map((entity) => Category.fromEntity(entity).copyWith(
               createdAt: DateTime.now(),
               updatedAt: DateTime.now(),
             ))
         .toList();

     final insertedCategories = await _localDataSource.bulkInsertCategories(categoryModels);
     return insertedCategories.map((category) => category.toEntity()).toList();
   } catch (e) {
     if (e is CategoryRepositoryException) rethrow;
     throw CategoryRepositoryException('Failed to bulk create categories', e);
   }
 }

 @override
 Future<void> bulkUpdateCategories(List<CategoryEntity> categories) async {
   try {
     // Validate all categories have IDs
     for (final category in categories) {
       if (category.id == null) {
         throw CategoryRepositoryException('Cannot update category without ID', null);
       }
       _validateCategory(category);
     }

     // Convert to data models
     final categoryModels = categories
         .map((entity) => Category.fromEntity(entity))
         .toList();

     await _localDataSource.bulkUpdateCategories(categoryModels);
   } catch (e) {
     if (e is CategoryRepositoryException) rethrow;
     throw CategoryRepositoryException('Failed to bulk update categories', e);
   }
 }

 @override
 Future<void> bulkDeleteCategories(List<int> ids) async {
   try {
     if (ids.isEmpty) return;

     // Check if any categories are default or have expenses
     for (final id in ids) {
       final category = await _localDataSource.getCategoryById(id);
       if (category == null) continue;

       if (category.isDefault) {
         throw CategoryRepositoryException('Cannot delete default category (ID: $id)', null);
       }
     }

     await _localDataSource.bulkDeleteCategories(ids);
   } catch (e) {
     if (e is CategoryRepositoryException) rethrow;
     throw CategoryRepositoryException('Failed to bulk delete categories', e);
   }
 }

 @override
 Future<void> resetToDefaultCategories() async {
   try {
     // Get all user categories
     final userCategories = await _localDataSource.getUserCategories();
     
     // Soft delete all user categories
     if (userCategories.isNotEmpty) {
       final userIds = userCategories.map((c) => c.id!).toList();
       await _localDataSource.bulkDeleteCategories(userIds);
     }

     // Restore all default categories
     final allDefaults = await _localDataSource.getDefaultCategories();
     final inactiveDefaults = allDefaults.where((c) => !c.isActive).toList();
     
     if (inactiveDefaults.isNotEmpty) {
       for (final category in inactiveDefaults) {
         await _localDataSource.restoreCategory(category.id!);
       }
     }

     // Create missing default categories
     await createDefaultCategories();
   } catch (e) {
     throw CategoryRepositoryException('Failed to reset to default categories', e);
   }
 }

 /// Validate category data
 void _validateCategory(CategoryEntity category) {
   if (category.name.trim().isEmpty) {
     throw CategoryRepositoryException('Category name cannot be empty', null);
   }

   if (category.name.trim().length > 50) {
     throw CategoryRepositoryException('Category name cannot exceed 50 characters', null);
   }

   if (category.iconCode <= 0) {
     throw CategoryRepositoryException('Invalid icon code', null);
   }
 }
}

/// Custom exception for category repository operations
class CategoryRepositoryException implements Exception {
 final String message;
 final dynamic originalError;
 
 const CategoryRepositoryException(this.message, this.originalError);
 
 @override
 String toString() {
   if (originalError != null) {
     return 'CategoryRepositoryException: $message\nCaused by: $originalError';
   }
   return 'CategoryRepositoryException: $message';
 }
}
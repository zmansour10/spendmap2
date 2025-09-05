import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/category_entity.dart';
import '../../data/models/category.dart';
import '../../../shared/providers/database_provider.dart';
import 'category_provider.dart';

part 'category_form_provider.g.dart';

// Category Form State Provider
@riverpod
class CategoryForm extends _$CategoryForm {
  @override
  CategoryFormState build() {
    return CategoryFormState.initial();
  }

  /// Initialize form for editing existing category
  void initializeForEdit(CategoryEntity category) {
    state = CategoryFormState(
      id: category.id,
      name: category.name,
      iconCode: category.iconCode,
      colorValue: category.colorValue,
      isDefault: category.isDefault,
      isActive: category.isActive,
      isEditing: true,
      originalCategory: category,
      isDirty: false,
      errors: {},
    );
  }

  /// Initialize form for creating new category
  void initializeForCreate({
    String? templateName,
    int? templateIconCode,
    int? templateColorValue,
  }) {
    state = CategoryFormState(
      id: null,
      name: templateName ?? '',
      iconCode: templateIconCode ?? Icons.category.codePoint,
      colorValue: templateColorValue ?? Colors.blue.value,
      isDefault: false,
      isActive: true,
      isEditing: false,
      originalCategory: null,
      isDirty:
          templateName != null ||
          templateIconCode != null ||
          templateColorValue != null,
      errors: {},
    );
  }

  /// Update category name
  void updateName(String name) {
    final trimmedName = name.trim();

    // Remove existing name error
    final updatedErrors = Map<CategoryFormError, String>.from(state.errors);
    updatedErrors.remove(CategoryFormError.name);

    state = state.copyWith(
      name: trimmedName,
      isDirty: true,
      errors: updatedErrors,
    );

    // Always validate name immediately for real-time feedback
    final syncError = _validateNameSync(trimmedName);

    if (syncError != null) {
      state = state.copyWith(
        errors: {...state.errors, CategoryFormError.name: syncError},
      );
    }
  }

  /// Update category icon
  // void updateIcon(int iconCode) {
  //   state = state.copyWith(iconCode: iconCode, isDirty: true);
  // }

  void updateIcon(int iconCode) {
    final updatedErrors = Map<CategoryFormError, String>.from(state.errors);
    updatedErrors.remove(CategoryFormError.icon);

    state = state.copyWith(
      iconCode: iconCode,
      isDirty: true,
      errors: updatedErrors,
    );
  }

  /// Update category color
  void updateColor(int colorValue) {
    final updatedErrors = Map<CategoryFormError, String>.from(state.errors);
    updatedErrors.remove(CategoryFormError.color);

    state = state.copyWith(
      colorValue: colorValue,
      isDirty: true,
      errors: updatedErrors,
    );
  }

  /// Update active status
  void updateActiveStatus(bool isActive) {
    state = state.copyWith(isActive: isActive, isDirty: true);
  }

  // Update the validateForm method to use synchronous validation for immediate feedback
  /// Validate the entire form
  Future<bool> validateForm() async {
    final errors = <CategoryFormError, String>{};

    // Validate name (synchronous part)
    final nameError = _validateNameSync(state.name);
    if (nameError != null) {
      errors[CategoryFormError.name] = nameError;
    } else {
      // Check for duplicates (async part)
      final duplicateError = await _validateNameAsync(state.name);
      if (duplicateError != null) {
        errors[CategoryFormError.name] = duplicateError;
      }
    }

    // Validate icon
    if (state.iconCode <= 0) {
      errors[CategoryFormError.icon] = 'Please select an icon';
    }

    // Validate color
    if (state.colorValue <= 0) {
      errors[CategoryFormError.color] = 'Please select a color';
    }

    state = state.copyWith(errors: errors);
    return errors.isEmpty;
  }

  /// Check for duplicate names (separated for clarity)
  Future<String?> _validateNameAsync(String name) async {
    try {
      final repository = ref.read(categoryRepositoryProvider);
      final nameExists = await repository.categoryNameExists(
        name,
        excludeId: state.id,
      );

      if (nameExists) {
        return 'A category with this name already exists';
      }

      return null;
    } catch (e) {
      // If we can't check for duplicates now, it will be caught during save
      return null;
    }
  }

  /// Validate name (synchronous version for immediate feedback)
  String? _validateNameSync(String name){
    if (name.isEmpty) {
      return 'Category name is required';
    }

    if (name.length < 2) {
      return 'Category name must be at least 2 characters';
    }

    if (name.length > 50) {
      return 'Category name cannot exceed 50 characters';
    }

    if (name.contains(RegExp(r'[<>:"\/\\|?*]'))) {
      return 'Category name contains invalid characters';
    }

    return null;
  }

  /// Validate name and check for duplicates (async version)
  Future<String?> _validateName(String name) async {
    // First do synchronous validation
    final syncError = _validateNameSync(name);
    if (syncError != null) {
      state = state.copyWith(
        errors: {...state.errors, CategoryFormError.name: syncError},
      );
      return syncError;
    }

    // Then check for duplicate names
    try {
      final repository = ref.read(categoryRepositoryProvider);
      final nameExists = await repository.categoryNameExists(
        name,
        excludeId: state.id,
      );

      if (nameExists) {
        final error = 'A category with this name already exists';
        state = state.copyWith(
          errors: {...state.errors, CategoryFormError.name: error},
        );
        return error;
      }

      // Remove error if validation passed
      final updatedErrors = Map<CategoryFormError, String>.from(state.errors);
      updatedErrors.remove(CategoryFormError.name);
      state = state.copyWith(errors: updatedErrors);

      return null;
    } catch (e) {
      // If we can't check for duplicates, we'll catch it during save
      return null;
    }
  }

  /// Save the category (create or update)
  Future<CategoryFormResult> save() async {
    // Set submitting state
    state = state.copyWith(isSubmitting: true);

    try {
      // Validate form first
      final isValid = await validateForm();
      if (!isValid) {
        state = state.copyWith(isSubmitting: false);
        return CategoryFormResult.validationError(state.errors);
      }

      final repository = ref.read(categoryRepositoryProvider);
      final categoryEntity = state.toEntity();

      CategoryEntity savedCategory;

      if (state.isEditing && state.id != null) {
        // Update existing category
        savedCategory = await repository.updateCategory(categoryEntity);
      } else {
        // Create new category
        savedCategory = await repository.createCategory(categoryEntity);
      }

      // Update form state with saved data
      state = state.copyWith(
        id: savedCategory.id,
        name: savedCategory.name,
        iconCode: savedCategory.iconCode,
        colorValue: savedCategory.colorValue,
        isActive: savedCategory.isActive,
        isDirty: false,
        isSubmitting: false,
        errors: {},
        originalCategory: savedCategory,
      );

      // Refresh category providers
      ref.invalidate(categoriesProvider);
      ref.invalidate(activeCategoriesProvider);

      return CategoryFormResult.success(savedCategory);
    } catch (e) {
      state = state.copyWith(isSubmitting: false);

      // Parse specific error messages
      String errorMessage = e.toString();
      if (errorMessage.contains('already exists')) {
        state = state.copyWith(
          errors: {
            ...state.errors,
            CategoryFormError.name: 'A category with this name already exists',
          },
        );
        return CategoryFormResult.validationError(state.errors);
      }

      return CategoryFormResult.saveError(errorMessage);
    }
  }

  /// Reset form to original state (for editing) or initial state (for creating)
  void reset() {
    if (state.originalCategory != null) {
      initializeForEdit(state.originalCategory!);
    } else {
      initializeForCreate();
    }
  }

  /// Clear all form data
  void clear() {
    state = CategoryFormState.initial();
  }

  /// Check if form has unsaved changes
  bool get hasUnsavedChanges => state.isDirty;

  /// Get current form validation state
  //bool get isValid => state.errors.isEmpty && state.name.isNotEmpty;
  bool get isValid {
    final hasValidName =
        state.name.isNotEmpty &&
        state.name.length >= 2 &&
        state.name.length <= 50;
    final hasValidIcon = state.iconCode > 0;
    final hasValidColor = state.colorValue > 0;

    return hasValidName &&
        hasValidIcon &&
        hasValidColor &&
        state.errors.isEmpty;
  }

  /// Check if form can be saved
  bool get canSave => isValid && !state.isSubmitting;
}

// Category Template Provider (for quick category creation)
@riverpod
List<CategoryTemplate> categoryTemplates(CategoryTemplatesRef ref) {
  return CategoryTemplates.templates;
}

// Category Template by Name Provider
@riverpod
CategoryTemplate? categoryTemplateByName(
  CategoryTemplateByNameRef ref,
  String templateName,
) {
  return CategoryTemplates.getTemplate(templateName);
}

// Category Icon Search Provider
@riverpod
class CategoryIconSearch extends _$CategoryIconSearch {
  @override
  List<CategoryIconOption> build() {
    return _getDefaultIcons();
  }

  /// Search icons by query
  void search(String query) {
    if (query.trim().isEmpty) {
      state = _getDefaultIcons();
      return;
    }

    final lowerQuery = query.toLowerCase();
    state = _getAllIcons()
        .where(
          (icon) =>
              icon.name.toLowerCase().contains(lowerQuery) ||
              icon.keywords.any(
                (keyword) => keyword.toLowerCase().contains(lowerQuery),
              ),
        )
        .toList();
  }

  /// Reset to default icons
  void resetToDefault() {
    state = _getDefaultIcons();
  }

  List<CategoryIconOption> _getDefaultIcons() {
    return [
      CategoryIconOption(Icons.restaurant.codePoint, 'Restaurant', [
        'food',
        'dining',
      ]),
      CategoryIconOption(Icons.directions_car.codePoint, 'Car', [
        'transport',
        'vehicle',
      ]),
      CategoryIconOption(Icons.shopping_bag.codePoint, 'Shopping', [
        'shop',
        'buy',
      ]),
      CategoryIconOption(Icons.movie.codePoint, 'Entertainment', [
        'fun',
        'leisure',
      ]),
      CategoryIconOption(Icons.receipt.codePoint, 'Bills', [
        'utilities',
        'payment',
      ]),
      CategoryIconOption(Icons.local_hospital.codePoint, 'Healthcare', [
        'medical',
        'health',
      ]),
      CategoryIconOption(Icons.school.codePoint, 'Education', [
        'learning',
        'study',
      ]),
      CategoryIconOption(Icons.flight.codePoint, 'Travel', [
        'trip',
        'vacation',
      ]),
      CategoryIconOption(Icons.spa.codePoint, 'Personal Care', [
        'beauty',
        'wellness',
      ]),
      CategoryIconOption(Icons.home.codePoint, 'Home', ['house', 'property']),
      CategoryIconOption(Icons.fitness_center.codePoint, 'Fitness', [
        'gym',
        'exercise',
      ]),
      CategoryIconOption(Icons.pets.codePoint, 'Pets', ['animals', 'pet care']),
      CategoryIconOption(Icons.local_gas_station.codePoint, 'Fuel', [
        'gas',
        'petrol',
        'fuel',
      ]),
      CategoryIconOption(Icons.phone.codePoint, 'Phone', [
        'mobile',
        'communication',
        'call',
      ]),
      CategoryIconOption(Icons.card_giftcard.codePoint, 'Gifts', [
        'present',
        'gift',
        'donation',
      ]),
    ];
  }

  List<CategoryIconOption> _getAllIcons() {
    return [
      ..._getDefaultIcons(),
      CategoryIconOption(Icons.agriculture.codePoint, 'Agriculture', [
        'farming',
        'garden',
        'plants',
      ]),
      CategoryIconOption(Icons.music_note.codePoint, 'Music', [
        'sound',
        'audio',
        'song',
      ]),
      CategoryIconOption(Icons.camera.codePoint, 'Photography', [
        'photo',
        'camera',
        'picture',
      ]),
      CategoryIconOption(Icons.sports.codePoint, 'Sports', [
        'game',
        'sport',
        'ball',
      ]),
      CategoryIconOption(Icons.computer.codePoint, 'Technology', [
        'tech',
        'computer',
        'software',
      ]),
      CategoryIconOption(Icons.kitchen.codePoint, 'Kitchen', [
        'cooking',
        'cook',
        'kitchen',
      ]),
      CategoryIconOption(Icons.child_care.codePoint, 'Childcare', [
        'baby',
        'child',
        'kids',
      ]),
      CategoryIconOption(Icons.elderly.codePoint, 'Elderly Care', [
        'senior',
        'elderly',
        'care',
      ]),
      CategoryIconOption(Icons.beach_access.codePoint, 'Vacation', [
        'beach',
        'holiday',
        'relax',
      ]),
      CategoryIconOption(Icons.business.codePoint, 'Business', [
        'company',
        'corporate',
        'office',
      ]),
    ];
  }
}

/// Category form state
class CategoryFormState {
  final int? id;
  final String name;
  final int iconCode;
  final int colorValue;
  final bool isDefault;
  final bool isActive;
  final bool isEditing;
  final CategoryEntity? originalCategory;
  final bool isDirty;
  final bool isSubmitting;
  final Map<CategoryFormError, String> errors;

  const CategoryFormState({
    this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.isDefault,
    required this.isActive,
    required this.isEditing,
    this.originalCategory,
    required this.isDirty,
    this.isSubmitting = false,
    required this.errors,
  });

  factory CategoryFormState.initial() {
    return CategoryFormState(
      name: '',
      iconCode: Icons.category.codePoint,
      colorValue: Colors.blue.value,
      isDefault: false,
      isActive: true,
      isEditing: false,
      isDirty: false,
      errors: {},
    );
  }

  CategoryFormState copyWith({
    int? id,
    String? name,
    int? iconCode,
    int? colorValue,
    bool? isDefault,
    bool? isActive,
    bool? isEditing,
    CategoryEntity? originalCategory,
    bool? isDirty,
    bool? isSubmitting,
    Map<CategoryFormError, String>? errors,
  }) {
    return CategoryFormState(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      isEditing: isEditing ?? this.isEditing,
      originalCategory: originalCategory ?? this.originalCategory,
      isDirty: isDirty ?? this.isDirty,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errors: errors ?? this.errors,
    );
  }

  /// Convert form state to category entity
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      iconCode: iconCode,
      colorValue: colorValue,
      isDefault: isDefault,
      isActive: isActive,
      createdAt: originalCategory?.createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// Get form validation summary
  CategoryFormValidation get validation {
    // Check if name meets basic requirements
    final hasValidName =
        name.isNotEmpty && name.length >= 2 && name.length <= 50;
    final hasValidIcon = iconCode > 0;
    final hasValidColor = colorValue > 0;

    // All basic requirements must be met AND no validation errors
    final isValid =
        hasValidName && hasValidIcon && hasValidColor && errors.isEmpty;

    final hasErrors = errors.isNotEmpty || !hasValidName;

    return CategoryFormValidation(
      isValid: isValid,
      hasErrors: hasErrors,
      errorCount: errors.length,
      errors: errors,
    );
  }

  /// Check if form has changes from original
  bool get hasChanges {
    if (originalCategory == null) return isDirty;

    return name != originalCategory!.name ||
        iconCode != originalCategory!.iconCode ||
        colorValue != originalCategory!.colorValue ||
        isActive != originalCategory!.isActive;
  }

  /// Get icon data
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

  /// Get color
  Color get color => Color(colorValue);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryFormState &&
        other.id == id &&
        other.name == name &&
        other.iconCode == iconCode &&
        other.colorValue == colorValue &&
        other.isDefault == isDefault &&
        other.isActive == isActive &&
        other.isEditing == isEditing &&
        other.isDirty == isDirty &&
        other.isSubmitting == isSubmitting;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      iconCode,
      colorValue,
      isDefault,
      isActive,
      isEditing,
      isDirty,
      isSubmitting,
    );
  }

  @override
  String toString() {
    return 'CategoryFormState(id: $id, name: "$name", isEditing: $isEditing, isDirty: $isDirty, errors: ${errors.length})';
  }
}

/// Form validation errors
enum CategoryFormError { name, icon, color, duplicate, network }

/// Form validation result
class CategoryFormValidation {
  final bool isValid;
  final bool hasErrors;
  final int errorCount;
  final Map<CategoryFormError, String> errors;

  const CategoryFormValidation({
    required this.isValid,
    required this.hasErrors,
    required this.errorCount,
    required this.errors,
  });

  String? getError(CategoryFormError field) => errors[field];
  bool hasError(CategoryFormError field) => errors.containsKey(field);

  /// Get first error message for display
  String? get firstErrorMessage {
    if (errors.isEmpty) return null;
    return errors.values.first;
  }

  /// Get all error messages as a list
  List<String> get allErrorMessages => errors.values.toList();
}

/// Form operation result
class CategoryFormResult {
  final bool isSuccess;
  final CategoryEntity? category;
  final String? errorMessage;
  final Map<CategoryFormError, String>? validationErrors;

  const CategoryFormResult._({
    required this.isSuccess,
    this.category,
    this.errorMessage,
    this.validationErrors,
  });

  factory CategoryFormResult.success(CategoryEntity category) {
    return CategoryFormResult._(isSuccess: true, category: category);
  }

  factory CategoryFormResult.saveError(String message) {
    return CategoryFormResult._(isSuccess: false, errorMessage: message);
  }

  factory CategoryFormResult.validationError(
    Map<CategoryFormError, String> errors,
  ) {
    return CategoryFormResult._(isSuccess: false, validationErrors: errors);
  }

  /// Check if result has validation errors
  bool get hasValidationErrors => validationErrors != null && validationErrors!.isNotEmpty;

  /// Get first validation error message
  String? get firstValidationError {
    if (validationErrors == null || validationErrors!.isEmpty) return null;
    return validationErrors!.values.first;
  }
}

/// Icon option for category selection
class CategoryIconOption {
  final int codePoint;
  final String name;
  final List<String> keywords;

  const CategoryIconOption(this.codePoint, this.name, this.keywords);

  IconData get iconData => IconData(codePoint, fontFamily: 'MaterialIcons');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryIconOption && other.codePoint == codePoint;
  }

  @override
  int get hashCode => codePoint.hashCode;

  @override
  String toString() => 'CategoryIconOption(name: $name, codePoint: $codePoint)';
}

/// Category statistics model
class CategoryStats {
  final int totalCount;
  final int activeCount;
  final int inactiveCount;
  final int userCreatedCount;
  final int defaultCount;

  const CategoryStats({
    required this.totalCount,
    required this.activeCount,
    required this.inactiveCount,
    required this.userCreatedCount,
    required this.defaultCount,
  });

  double get activePercentage =>
      totalCount > 0 ? (activeCount / totalCount) * 100 : 0;
  double get userCreatedPercentage =>
      totalCount > 0 ? (userCreatedCount / totalCount) * 100 : 0;
  double get inactivePercentage =>
      totalCount > 0 ? (inactiveCount / totalCount) * 100 : 0;

  @override
  String toString() {
    return 'CategoryStats(total: $totalCount, active: $activeCount, inactive: $inactiveCount, user: $userCreatedCount, default: $defaultCount)';
  }
}

/// Category operation result
class CategoryOperationResult {
  final bool isSuccess;
  final String message;
  final dynamic data;

  const CategoryOperationResult._({
    required this.isSuccess,
    required this.message,
    this.data,
  });

  factory CategoryOperationResult.success(String message, {dynamic data}) {
    return CategoryOperationResult._(
      isSuccess: true,
      message: message,
      data: data,
    );
  }

  factory CategoryOperationResult.error(String message) {
    return CategoryOperationResult._(isSuccess: false, message: message);
  }

  @override
  String toString() {
    return 'CategoryOperationResult(success: $isSuccess, message: "$message")';
  }

}

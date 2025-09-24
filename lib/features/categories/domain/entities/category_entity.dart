import 'package:flutter/material.dart';

/// Domain entity representing a category
class CategoryEntity {
  final int? id;
  final String name;
  final int iconCode;
  final int colorValue;
  final bool isDefault;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryEntity({
    this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
    required this.isDefault,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  // * Business logic methods
  
  /// Check if category can be deleted.
  bool get canBeDeleted => !isDefault && isActive;

  /// Check if category can be edited.
  bool get canBeEdited => !isDefault;

  /// Get Flutter Icon from iconCode.
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');

  /// Get Flutter Color from colorValue.
  Color get color => Color(colorValue);

  /// Check if category is system-defined.
  bool get isSystemCategory => isDefault;

  /// Check if category is user-created.
  bool get isUserCategory => !isDefault;

  /// Create a copy of the current entity with updated fields.
  CategoryEntity copyWith({
    int? id,
    String? name,
    int? iconCode,
    int? colorValue,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create inactive copy
  CategoryEntity deactivate() {
    return copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );
  }

  /// Create active copy
  CategoryEntity activate() {
    return copyWith(
      isActive: true,
      updatedAt: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CategoryEntity &&
        other.id == id &&
        other.name == name &&
        other.iconCode == iconCode &&
        other.colorValue == colorValue &&
        other.isDefault == isDefault &&
        other.isActive == isActive;
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
    );
  }

  @override
  String toString() {
    return 'CategoryEntity(id: $id, name: $name, isDefault: $isDefault, isActive: $isActive)';
  }
}
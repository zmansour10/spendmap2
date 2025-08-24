import 'package:flutter/material.dart';

// * Domain entity representing a category
// * This is the core business object - no dependencies on external frameworks
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
  
  /// Check if category can be deleted
  bool get canBeDeleted => !isDefault && isActive;
  
  /// Check if category can be edited
  bool get canBeEdited => !isDefault;
  
  /// Get Flutter Icon from iconCode
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  // IconData get icon => IconData(iconCode ?? 0xe14c, fontFamily: 'MaterialIcons'); // helper_outline as default if iconCode is null
  
  /// Get Flutter Color from colorValue
  Color get color => Color(colorValue);
  // Color get color => Color(colorValue ?? 0xFF000000); // Black as default if colorValue is null
  
  /// Check if category is system-defined
  bool get isSystemCategory => isDefault;
  
  /// Check if category is user-created
  bool get isUserCategory => !isDefault;

  /// Create a copy with modified properties
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

  /// Create inactive (soft deleted) copy
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
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/category_entity.dart';

part 'category.freezed.dart';
part 'category.g.dart';

/// Data model for Category with JSON serialization
/// This handles data persistence and API communication
@freezed
abstract class Category with _$Category {
  const factory Category({
    int? id,
    required String name,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'icon_code') required int iconCode,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'color') required int colorValue,
    //ignore: invalid_annotation_target
    @JsonKey(name: 'is_default') required bool isDefault,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'created_at') DateTime? createdAt,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Category;

  /// Create from JSON (database or API)
  factory Category.fromJson(Map<String, dynamic> json) => _$CategoryFromJson(json);

  /// Create from database map (SQLite specific)
  factory Category.fromDatabase(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      iconCode: map['icon_code'] as int,
      colorValue: map['color_value'] as int,
      isDefault: (map['is_default'] as int) == 1,
      isActive: (map['is_active'] as int) == 1,
      createdAt: map['created_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }

  const Category._();

  /// Convert to database map 
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'icon_code': iconCode,
      'color_value': colorValue,
      'is_default': isDefault ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      if (createdAt != null) 'created_at': createdAt!.millisecondsSinceEpoch,
      if (updatedAt != null) 'updated_at': updatedAt!.millisecondsSinceEpoch,
    };
  }

  /// Convert the Category to domain entity
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      iconCode: iconCode,
      colorValue: colorValue,
      isDefault: isDefault,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create a Category from domain entity
  factory Category.fromEntity(CategoryEntity entity) {
    return Category(
      id: entity.id,
      name: entity.name,
      iconCode: entity.iconCode,
      colorValue: entity.colorValue,
      isDefault: entity.isDefault,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // * Helper getters like CategoryEntity *
  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);
  bool get canBeDeleted => !isDefault && isActive;
  bool get canBeEdited => !isDefault;
}

/// Template for creating categories
class CategoryTemplate {
  final String name;
  final int iconCode;
  final int colorValue;

  const CategoryTemplate({
    required this.name,
    required this.iconCode,
    required this.colorValue,
  });

  IconData get icon => IconData(iconCode, fontFamily: 'MaterialIcons');
  Color get color => Color(colorValue);
}

/// Category templates for easy category creation
class CategoryTemplates {
  static const List<CategoryTemplate> templates = [
    CategoryTemplate(
      name: 'Food & Dining',
      iconCode: 0xe56c, // Icons.restaurant
      colorValue: 0xFFE57373, // Red
    ),
    CategoryTemplate(
      name: 'Transportation',
      iconCode: 0xe531, // Icons.directions_car
      colorValue: 0xFF64B5F6, // Blue
    ),
    CategoryTemplate(
      name: 'Shopping',
      iconCode: 0xe8cc, // Icons.shopping_bag
      colorValue: 0xFFBA68C8, // Purple
    ),
    CategoryTemplate(
      name: 'Entertainment',
      iconCode: 0xe02c, // Icons.movie
      colorValue: 0xFFFFB74D, // Orange
    ),
    CategoryTemplate(
      name: 'Bills & Utilities',
      iconCode: 0xe9c6, // Icons.receipt
      colorValue: 0xFF4DB6AC, // Teal
    ),
    CategoryTemplate(
      name: 'Healthcare',
      iconCode: 0xe575, // Icons.local_hospital
      colorValue: 0xFF81C784, // Green
    ),
    CategoryTemplate(
      name: 'Education',
      iconCode: 0xe80c, // Icons.school
      colorValue: 0xFF7986CB, // Indigo
    ),
    CategoryTemplate(
      name: 'Travel',
      iconCode: 0xe539, // Icons.flight
      colorValue: 0xFFF06292, // Pink
    ),
    CategoryTemplate(
      name: 'Personal Care',
      iconCode: 0xeb8c, // Icons.spa
      colorValue: 0xFFAED581, // Light Green
    ),
    CategoryTemplate(
      name: 'Gifts & Donations',
      iconCode: 0xe8f6, // Icons.card_giftcard
      colorValue: 0xFFFFAB91, // Deep Orange Light
    ),
    CategoryTemplate(
      name: 'Home & Garden',
      iconCode: 0xe88a, // Icons.home
      colorValue: 0xFF8D6E63, // Brown
    ),
    CategoryTemplate(
      name: 'Other',
      iconCode: 0xe5d4, // Icons.more_horiz
      colorValue: 0xFF90A4AE, // Blue Grey
    ),
  ];

  /// Get template by name
  static CategoryTemplate? getTemplate(String name) {
    try {
      return templates.firstWhere((template) => template.name == name);
    } catch (e) {
      return null;
    }
  }

  /// Create category from template
  static Category createFromTemplate(CategoryTemplate template, {bool isDefault = false}) {
    return Category(
      name: template.name,
      iconCode: template.iconCode,
      colorValue: template.colorValue,
      isDefault: isDefault,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}


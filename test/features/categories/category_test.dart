import 'package:flutter_test/flutter_test.dart';
import 'package:spendmap2/features/categories/data/models/category.dart';
import 'package:spendmap2/features/categories/domain/entities/category_entity.dart';

void main() {
  group('Category System Tests', () {
    test('should create category entity correctly', () {
      final category = CategoryEntity(
        id: 1,
        name: 'Test Category',
        iconCode: 123,
        colorValue: 0xFF000000,
        isDefault: false,
      );

      expect(category.id, equals(1));
      expect(category.name, equals('Test Category'));
      expect(category.canBeDeleted, isTrue);
      expect(category.canBeEdited, isTrue);
    });

    test('should convert between entity and model correctly', () {
      final entity = CategoryEntity(
        id: 1,
        name: 'Test Category',
        iconCode: 123,
        colorValue: 0xFF000000,
        isDefault: false,
      );

      // Convert to model
      final model = Category.fromEntity(entity);
      expect(model.name, equals(entity.name));
      expect(model.iconCode, equals(entity.iconCode));

      // Convert back to entity
      final convertedEntity = model.toEntity();
      expect(convertedEntity.name, equals(entity.name));
      expect(convertedEntity.iconCode, equals(entity.iconCode));
    });

    test('should create category from template', () {
      final template = CategoryTemplates.templates.first;
      final category = CategoryTemplates.createFromTemplate(template);

      expect(category.name, equals(template.name));
      expect(category.iconCode, equals(template.iconCode));
      expect(category.colorValue, equals(template.colorValue));
    });

    test('should handle database conversion', () {
      final category = Category(
        id: 1,
        name: 'Test Category',
        iconCode: 123,
        colorValue: 0xFF000000,
        isDefault: false,
        createdAt: DateTime.now(),
      );

      // Convert to database map
      final dbMap = category.toDatabase();
      expect(dbMap['name'], equals('Test Category'));
      expect(dbMap['is_default'], equals(0));

      // Convert back from database map
      final fromDb = Category.fromDatabase(dbMap);
      expect(fromDb.name, equals('Test Category'));
      expect(fromDb.isDefault, isFalse);
    });
  });
}
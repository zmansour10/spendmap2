import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/expense_entity.dart';
import '../../../categories/domain/entities/category_entity.dart';

part 'expense.freezed.dart';
part 'expense.g.dart';

/// Data model for Expense with JSON serialization
@freezed
abstract class Expense with _$Expense {
  const factory Expense({
    int? id,
    required double amount,
    required String description,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'category_id') required int categoryId,
    required DateTime date,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'created_at') DateTime? createdAt,
    // ignore: invalid_annotation_target
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _Expense;

  /// Create from JSON (API or export)
  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);

  /// Create from database map (SQLite specific)
  factory Expense.fromDatabase(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String? ?? '',
      categoryId: map['category_id'] as int,
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      createdAt: map['created_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }

  const Expense._();

  /// Convert to database map (SQLite specific)
  Map<String, dynamic> toDatabase() {
    return {
      if (id != null) 'id': id,
      'amount': amount,
      'description': description,
      'category_id': categoryId,
      'date': date.millisecondsSinceEpoch,
      if (createdAt != null) 'created_at': createdAt!.millisecondsSinceEpoch,
      if (updatedAt != null) 'updated_at': updatedAt!.millisecondsSinceEpoch,
    };
  }

  /// Convert to domain entity
  ExpenseEntity toEntity() {
    return ExpenseEntity(
      id: id,
      amount: amount,
      description: description,
      categoryId: categoryId,
      date: date,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory Expense.fromEntity(ExpenseEntity entity) {
    return Expense(
      id: entity.id,
      amount: entity.amount,
      description: entity.description,
      categoryId: entity.categoryId,
      date: entity.date,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Helper getters (delegate to entity logic)
  bool get isValid => toEntity().isValid;
  bool get isToday => toEntity().isToday;
  bool get isThisMonth => toEntity().isThisMonth;
  String get displayDescription => toEntity().displayDescription;
  String get monthYearKey => toEntity().monthYearKey;
}

/// Extended expense model with category information
/// Used for joined queries and display purposes
@freezed
abstract class ExpenseWithCategory with _$ExpenseWithCategory {
  const factory ExpenseWithCategory({
    required int id,
    required double amount,
    required String description,
    required DateTime date,
    DateTime? createdAt,
    DateTime? updatedAt,
    // Category information
    required int categoryId,
    required String categoryName,
    required int categoryIcon,
    required int categoryColor,
  }) = _ExpenseWithCategory;

  /// Create from database join result
  factory ExpenseWithCategory.fromDatabase(Map<String, dynamic> map) {
    return ExpenseWithCategory(
      id: map['id'] as int,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String? ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      createdAt: map['created_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
      categoryId: map['category_id'] as int,
      categoryName: map['category_name'] as String,
      categoryIcon: map['category_icon'] as int,
      categoryColor: map['category_color'] as int,
    );
  }

  const ExpenseWithCategory._();

  /// Convert to expense entity
  ExpenseEntity toExpenseEntity() {
    return ExpenseEntity(
      id: id,
      amount: amount,
      description: description,
      categoryId: categoryId,
      date: date,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Get category entity
  CategoryEntity getCategoryEntity() {
    return CategoryEntity(
      id: categoryId,
      name: categoryName,
      iconCode: categoryIcon,
      colorValue: categoryColor,
      isDefault: true, // We don't have this info in the join, assume true
      isActive: true,  // We don't have this info in the join, assume true
    );
  }
}

/// Expense statistics model
@freezed
abstract class ExpenseStats with _$ExpenseStats {
  const factory ExpenseStats({
    required double totalAmount,
    required int expenseCount,
    required double averageAmount,
    required double highestAmount,
    required double lowestAmount,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) = _ExpenseStats;

  const ExpenseStats._();

  /// Create empty stats
  factory ExpenseStats.empty() {
    return const ExpenseStats(
      totalAmount: 0,
      expenseCount: 0,
      averageAmount: 0,
      highestAmount: 0,
      lowestAmount: 0,
    );
  }

  /// Check if stats are empty
  bool get isEmpty => expenseCount == 0;

  /// Get formatted total amount
  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)}';

  /// Get formatted average amount
  String get formattedAverage => '\$${averageAmount.toStringAsFixed(2)}';
}

/// Category expense summary for statistics
@freezed
abstract class CategoryExpenseSummary with _$CategoryExpenseSummary {
  const factory CategoryExpenseSummary({
    required int categoryId,
    required String categoryName,
    required int categoryIcon,
    required int categoryColor,
    required double totalAmount,
    required int expenseCount,
    required double averageAmount,
    required double percentage, // Percentage of total expenses
  }) = _CategoryExpenseSummary;

  const CategoryExpenseSummary._();

  /// Get formatted total amount
  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)}';

  /// Get formatted average amount  
  String get formattedAverage => '\$${averageAmount.toStringAsFixed(2)}';

  /// Get formatted percentage
  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';
}

/// Monthly expense summary
@freezed
abstract class MonthlyExpenseSummary with _$MonthlyExpenseSummary {
  const factory MonthlyExpenseSummary({
    required String month, // Format: "2024-01"
    required double totalAmount,
    required int expenseCount,
    required double averageAmount,
    required List<CategoryExpenseSummary> categoryBreakdown,
  }) = _MonthlyExpenseSummary;

  const MonthlyExpenseSummary._();

  /// Get month display name (e.g., "January 2024")
  String get displayMonth {
    final parts = month.split('-');
    if (parts.length != 2) return month;
    
    final year = int.tryParse(parts[0]) ?? 0;
    final monthNum = int.tryParse(parts[1]) ?? 0;
    
    const monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    if (monthNum < 1 || monthNum > 12) return month;
    return '${monthNames[monthNum]} $year';
  }

  /// Get formatted total amount
  String get formattedTotal => '\$${totalAmount.toStringAsFixed(2)}';
}
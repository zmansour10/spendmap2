import 'package:flutter/material.dart';

/// Domain entity representing an expense
/// Contains all business logic and validation rules
class ExpenseEntity {
  final int? id;
  final double amount;
  final String description;
  final int categoryId;
  final DateTime date;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ExpenseEntity({
    this.id,
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.date,
    this.createdAt,
    this.updatedAt,
  });

  /// Business logic methods

  /// Check if expense is valid
  bool get isValid => amount > 0 && categoryId > 0;

  /// Check if expense was created today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  /// Check if expense was created this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    return date.isAfter(startOfWeek) && date.isBefore(endOfWeek);
  }

  /// Check if expense was created this month
  bool get isThisMonth {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Check if expense was created this year
  bool get isThisYear {
    final now = DateTime.now();
    return date.year == now.year;
  }

  /// Get formatted amount string
  String getFormattedAmount({String currency = 'USD', String locale = 'en_US'}) {
    // This will be enhanced with proper currency formatting later
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Get description or default text
  String get displayDescription {
    if (description.trim().isEmpty) {
      return 'No description';
    }
    return description.trim();
  }

  /// Check if description is empty
  bool get hasDescription => description.trim().isNotEmpty;

  /// Get month-year key for grouping (e.g., "2024-01")
  String get monthYearKey => '${date.year}-${date.month.toString().padLeft(2, '0')}';

  /// Get date key for grouping (e.g., "2024-01-15")
  String get dateKey => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  /// Get week key for grouping
  String get weekKey {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return '${startOfWeek.year}-W${_getWeekOfYear(startOfWeek)}';
  }

  /// Check if expense is within date range
  bool isInDateRange(DateTime start, DateTime end) {
    return date.isAfter(start.subtract(const Duration(seconds: 1))) && 
           date.isBefore(end.add(const Duration(seconds: 1)));
  }

  /// Check if expense matches search query
  bool matchesSearchQuery(String query) {
    if (query.trim().isEmpty) return true;
    
    final lowerQuery = query.toLowerCase();
    return description.toLowerCase().contains(lowerQuery) ||
           amount.toString().contains(query);
  }

  /// Validate expense data
  List<String> validate() {
    final errors = <String>[];
    
    if (amount <= 0) {
      errors.add('Amount must be greater than zero');
    }
    
    if (amount > 999999.99) {
      errors.add('Amount cannot exceed \$999,999.99');
    }
    
    if (categoryId <= 0) {
      errors.add('Category is required');
    }
    
    if (description.length > 200) {
      errors.add('Description cannot exceed 200 characters');
    }
    
    if (date.isAfter(DateTime.now().add(const Duration(days: 1)))) {
      errors.add('Expense date cannot be in the future');
    }
    
    return errors;
  }

  /// Create a copy with modified properties
  ExpenseEntity copyWith({
    int? id,
    double? amount,
    String? description,
    int? categoryId,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ExpenseEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Create updated copy with current timestamp
  ExpenseEntity withUpdatedTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  /// Helper method to get week of year
  int _getWeekOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final daysDifference = date.difference(startOfYear).inDays;
    return ((daysDifference + startOfYear.weekday - 1) / 7).floor() + 1;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpenseEntity &&
        other.id == id &&
        other.amount == amount &&
        other.description == description &&
        other.categoryId == categoryId &&
        other.date == date;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      amount,
      description,
      categoryId,
      date,
    );
  }

  @override
  String toString() {
    return 'ExpenseEntity(id: $id, amount: $amount, description: "$description", categoryId: $categoryId, date: $date)';
  }
}

/// Enum for expense sorting options
enum ExpenseSortOption {
  dateNewest,
  dateOldest,
  amountHighest,
  amountLowest,
  description,
  category,
}

/// Extension for ExpenseSortOption
extension ExpenseSortOptionExtension on ExpenseSortOption {
  String get displayName {
    switch (this) {
      case ExpenseSortOption.dateNewest:
        return 'Date (Newest First)';
      case ExpenseSortOption.dateOldest:
        return 'Date (Oldest First)';
      case ExpenseSortOption.amountHighest:
        return 'Amount (Highest First)';
      case ExpenseSortOption.amountLowest:
        return 'Amount (Lowest First)';
      case ExpenseSortOption.description:
        return 'Description (A-Z)';
      case ExpenseSortOption.category:
        return 'Category';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseSortOption.dateNewest:
      case ExpenseSortOption.dateOldest:
        return Icons.date_range;
      case ExpenseSortOption.amountHighest:
      case ExpenseSortOption.amountLowest:
        return Icons.attach_money;
      case ExpenseSortOption.description:
        return Icons.text_fields;
      case ExpenseSortOption.category:
        return Icons.category;
    }
  }
}

/// Filter criteria for expenses
class ExpenseFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<int>? categoryIds;
  final double? minAmount;
  final double? maxAmount;
  final String? searchQuery;
  final ExpenseSortOption sortOption;
  final bool sortAscending;

  const ExpenseFilter({
    this.startDate,
    this.endDate,
    this.categoryIds,
    this.minAmount,
    this.maxAmount,
    this.searchQuery,
    this.sortOption = ExpenseSortOption.dateNewest,
    this.sortAscending = false,
  });

  /// Check if filter has any active criteria
  bool get hasActiveFilters {
    return startDate != null ||
           endDate != null ||
           (categoryIds != null && categoryIds!.isNotEmpty) ||
           minAmount != null ||
           maxAmount != null ||
           (searchQuery != null && searchQuery!.trim().isNotEmpty);
  }

  /// Create copy with modified properties
  ExpenseFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? categoryIds,
    double? minAmount,
    double? maxAmount,
    String? searchQuery,
    ExpenseSortOption? sortOption,
    bool? sortAscending,
  }) {
    return ExpenseFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryIds: categoryIds ?? this.categoryIds,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      sortAscending: sortAscending ?? this.sortAscending,
    );
  }

  /// Clear all filters
  ExpenseFilter clear() {
    return const ExpenseFilter();
  }

  @override
  String toString() {
    return 'ExpenseFilter(startDate: $startDate, endDate: $endDate, categories: ${categoryIds?.length}, minAmount: $minAmount, maxAmount: $maxAmount, query: "$searchQuery", sort: $sortOption)';
  }
}
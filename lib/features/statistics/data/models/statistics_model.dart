import '../../domain/entities/statistics.dart';

class StatisticsModel extends Statistics {
  const StatisticsModel({
    required super.totalExpenses,
    required super.averageExpense,
    required super.expenseCount,
    required super.mostSpentCategory,
    required super.mostSpentAmount,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      totalExpenses: (json['totalExpenses'] as num).toDouble(),
      averageExpense: (json['averageExpense'] as num).toDouble(),
      expenseCount: json['expenseCount'] as int,
      mostSpentCategory: json['mostSpentCategory'] as String,
      mostSpentAmount: (json['mostSpentAmount'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalExpenses': totalExpenses,
      'averageExpense': averageExpense,
      'expenseCount': expenseCount,
      'mostSpentCategory': mostSpentCategory,
      'mostSpentAmount': mostSpentAmount,
    };
  }
}
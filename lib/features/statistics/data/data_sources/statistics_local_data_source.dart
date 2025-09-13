import '../../domain/entities/statistics.dart';
import '../models/statistics_model.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../categories/domain/repositories/category_repository.dart';

abstract class StatisticsLocalDataSource {
  Future<Statistics> getStatistics();
}

class StatisticsLocalDataSourceImpl implements StatisticsLocalDataSource {
  final ExpenseRepository expenseRepository;
  final CategoryRepository categoryRepository;

  StatisticsLocalDataSourceImpl({
    required this.expenseRepository,
    required this.categoryRepository,
  });

  @override
  Future<Statistics> getStatistics() async {
    try {
      // Get total expenses amount
      final totalExpenses = await expenseRepository.getTotalExpenses();
      
      // Get expense count
      final expenseCount = await expenseRepository.getExpenseCount();
      
      // Calculate average expense
      double averageExpense = 0.0;
      if (expenseCount > 0) {
        averageExpense = totalExpenses / expenseCount;
      }
      
      // Get category expense summary to find most spent category
      final categoryExpenseSummary = await expenseRepository.getCategoryExpenseSummary();
      
      String mostSpentCategory = 'No expenses';
      double mostSpentAmount = 0.0;
      
      if (categoryExpenseSummary.isNotEmpty) {
        // Find the category with the highest total
        final topCategory = categoryExpenseSummary.reduce((a, b) => 
            a.totalAmount > b.totalAmount ? a : b);
        
        // Get category name
        final category = await categoryRepository.getCategoryById(topCategory.categoryId);
        mostSpentCategory = category?.name ?? 'Unknown';
        mostSpentAmount = topCategory.totalAmount;
      }
      
      return StatisticsModel(
        totalExpenses: totalExpenses,
        averageExpense: averageExpense,
        expenseCount: expenseCount,
        mostSpentCategory: mostSpentCategory,
        mostSpentAmount: mostSpentAmount,
      );
    } catch (e) {
      // Return default values if there's an error
      return const StatisticsModel(
        totalExpenses: 0.0,
        averageExpense: 0.0,
        expenseCount: 0,
        mostSpentCategory: 'No expenses',
        mostSpentAmount: 0.0,
      );
    }
  }
}
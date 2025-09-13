import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/app_scaffold.dart';
import '../providers/statistics_provider.dart';
import '../widgets/statistics_card.dart';

class StatisticsScreen extends ConsumerWidget {
  static const routeName = '/statistics';

  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statisticsAsync = ref.watch(statisticsProvider);

    return AppScaffold(
      title: 'Statistics',
      body: statisticsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading statistics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(statisticsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (statistics) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Expense Overview',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    StatisticsCard(
                      title: 'Total Expenses',
                      value: '\$${statistics.totalExpenses.toStringAsFixed(2)}',
                      icon: Icons.account_balance_wallet,
                      color: Theme.of(context).primaryColor,
                    ),
                    StatisticsCard(
                      title: 'Average Expense',
                      value: '\$${statistics.averageExpense.toStringAsFixed(2)}',
                      icon: Icons.trending_up,
                      color: Colors.green,
                    ),
                    StatisticsCard(
                      title: 'Total Count',
                      value: '${statistics.expenseCount}',
                      icon: Icons.receipt_long,
                      color: Colors.blue,
                    ),
                    StatisticsCard(
                      title: statistics.mostSpentCategory,
                      value: '\$${statistics.mostSpentAmount.toStringAsFixed(2)}',
                      icon: Icons.category,
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
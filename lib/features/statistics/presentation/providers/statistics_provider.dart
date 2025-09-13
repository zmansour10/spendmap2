import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/statistics.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../domain/use_cases/get_statistics_use_case.dart';
import '../../data/data_sources/statistics_local_data_source.dart';
import '../../data/repositories/statistics_repository_impl.dart';
import '../../../expenses/presentation/providers/expense_provider.dart';
import '../../../categories/presentation/providers/category_provider.dart';

// Data source provider
final statisticsLocalDataSourceProvider = Provider<StatisticsLocalDataSource>(
  (ref) => StatisticsLocalDataSourceImpl(
    expenseRepository: ref.read(expenseRepositoryProvider),
    categoryRepository: ref.read(categoryRepositoryProvider),
  ),
);

// Repository provider
final statisticsRepositoryProvider = Provider<StatisticsRepository>(
  (ref) => StatisticsRepositoryImpl(
    localDataSource: ref.read(statisticsLocalDataSourceProvider),
  ),
);

// Use case provider
final getStatisticsUseCaseProvider = Provider<GetStatisticsUseCase>(
  (ref) => GetStatisticsUseCase(
    ref.read(statisticsRepositoryProvider),
  ),
);

// Statistics provider
final statisticsProvider = FutureProvider<Statistics>((ref) async {
  final useCase = ref.read(getStatisticsUseCaseProvider);
  return await useCase.call();
});
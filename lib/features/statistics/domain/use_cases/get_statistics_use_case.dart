import '../entities/statistics.dart';
import '../repositories/statistics_repository.dart';

class GetStatisticsUseCase {
  final StatisticsRepository repository;

  GetStatisticsUseCase(this.repository);

  Future<Statistics> call() async {
    return await repository.getStatistics();
  }
}
import '../../domain/entities/statistics.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../data_sources/statistics_local_data_source.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsLocalDataSource localDataSource;

  StatisticsRepositoryImpl({required this.localDataSource});

  @override
  Future<Statistics> getStatistics() async {
    return await localDataSource.getStatistics();
  }
}
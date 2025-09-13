import '../entities/statistics.dart';

abstract class StatisticsRepository {
  Future<Statistics> getStatistics();
}
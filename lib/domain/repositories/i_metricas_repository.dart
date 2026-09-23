import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../entities/metricas_dashboard.dart';

abstract class IMetricasRepository {
  Future<Either<Failure, MetricasDashboard>> getDashboardMetrics();
}

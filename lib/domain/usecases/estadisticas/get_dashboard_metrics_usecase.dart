import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/metricas_dashboard.dart';
import '../../repositories/i_metricas_repository.dart';

class GetDashboardMetricsUseCase {
  final IMetricasRepository _repository;

  GetDashboardMetricsUseCase(this._repository);

  Future<Either<Failure, MetricasDashboard>> execute() {
    return _repository.getDashboardMetrics();
  }
}

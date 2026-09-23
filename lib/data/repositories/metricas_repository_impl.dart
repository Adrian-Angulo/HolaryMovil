import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/metricas_dashboard.dart';
import '../../domain/repositories/i_metricas_repository.dart';
import '../datasources/metricas_remote_datasource.dart';
import '../mappers/metricas_mapper.dart';

class MetricasRepositoryImpl implements IMetricasRepository {
  final IMetricasRemoteDataSource _remoteDataSource;

  MetricasRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, MetricasDashboard>> getDashboardMetrics() async {
    try {
      final apiModel = await _remoteDataSource.getDashboardMetrics();
      return Right(MetricasMapper.toDomain(apiModel));
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }
}

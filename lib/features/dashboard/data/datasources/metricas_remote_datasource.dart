import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/metricas_dashboard_api_model.dart';

abstract class IMetricasRemoteDataSource {
  Future<MetricasDashboardApiModel> getDashboardMetrics();
}

class MetricasRemoteDataSourceImpl implements IMetricasRemoteDataSource {
  final ApiClient _client;

  MetricasRemoteDataSourceImpl(this._client);

  @override
  Future<MetricasDashboardApiModel> getDashboardMetrics() async {
    final response = await _client.get(AppConstants.metricasDashboardEndpoint);
    return MetricasDashboardApiModel.fromJson(response as Map<String, dynamic>);
  }
}

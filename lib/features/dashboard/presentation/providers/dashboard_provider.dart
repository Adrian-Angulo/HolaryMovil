import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../perfil/presentation/providers/perfil_provider.dart';
import '../../../registros/presentation/providers/registro_provider.dart';
import '../../domain/entities/metricas_dashboard.dart';

/// Provider 100% Online-First para las métricas del Dashboard.
/// La fuente única de la verdad es el backend (`GET /api/v1/metricas/dashboard`).
/// Si la conexión falla, emite un error para que la UI presente el estado de reintento.
final dashboardMetricsProvider = FutureProvider<MetricasDashboard>((ref) async {
  // Observar cambios en perfil y registros para re-solicitar al backend
  ref.watch(registrosNotifierProvider);
  ref.watch(perfilNotifierProvider);

  final getMetricsUseCase = ref.read(getDashboardMetricsUseCaseProvider);
  final result = await getMetricsUseCase.execute();

  return result.fold(
    (failure) => throw failure,
    (metrics) => metrics,
  );
});

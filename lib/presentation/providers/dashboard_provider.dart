import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/metricas_dashboard.dart';
import '../../domain/entities/perfil.dart';
import 'dependency_injection.dart';
import 'perfil_provider.dart';
import 'registro_provider.dart';

final dashboardMetricsProvider = FutureProvider<MetricasDashboard>((ref) async {
  // Observar cambios en perfil y registros para re-calcular/re-cargar
  final registrosAsync = ref.watch(registrosNotifierProvider);
  final perfilAsync = ref.watch(perfilNotifierProvider);

  final getMetricsUseCase = ref.read(getDashboardMetricsUseCaseProvider);
  final result = await getMetricsUseCase.execute();

  return result.fold(
    (failure) {
      // Fallback de cálculo local
      final registros = registrosAsync.value ?? [];
      final perfil = perfilAsync.value ?? Perfil.defaultPerfil();
      final calculateMetricas = ref.read(calculateMetricasUseCaseProvider);

      return calculateMetricas.execute(
        registros: registros,
        perfil: perfil,
      );
    },
    (metrics) => metrics,
  );
});

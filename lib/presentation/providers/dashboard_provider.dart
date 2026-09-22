import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/metricas_dashboard.dart';
import '../../domain/entities/perfil.dart';
import 'dependency_injection.dart';
import 'perfil_provider.dart';
import 'registro_provider.dart';

final dashboardMetricsProvider = Provider<AsyncValue<MetricasDashboard>>((ref) {
  final registrosAsync = ref.watch(registrosNotifierProvider);
  final perfilAsync = ref.watch(perfilNotifierProvider);
  final calculateMetricas = ref.watch(calculateMetricasUseCaseProvider);

  if (registrosAsync.isLoading || perfilAsync.isLoading) {
    return const AsyncValue.loading();
  }

  if (registrosAsync.hasError) {
    return AsyncValue.error(registrosAsync.error!, registrosAsync.stackTrace!);
  }

  if (perfilAsync.hasError) {
    return AsyncValue.error(perfilAsync.error!, perfilAsync.stackTrace!);
  }

  final registros = registrosAsync.value ?? [];
  final perfil = perfilAsync.value ?? Perfil.defaultPerfil();

  final metricas = calculateMetricas.execute(
    registros: registros,
    perfil: perfil,
  );

  return AsyncValue.data(metricas);
});

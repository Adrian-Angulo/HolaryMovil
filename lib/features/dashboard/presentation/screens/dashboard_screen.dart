import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:practi_horas_app/core/theme/app_colors.dart';
import 'package:practi_horas_app/core/utils/date_formatters.dart';
import 'package:practi_horas_app/features/perfil/presentation/providers/perfil_provider.dart';
import 'package:practi_horas_app/features/registros/presentation/providers/registro_provider.dart';
import 'package:practi_horas_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:practi_horas_app/features/dashboard/presentation/widgets/molecules/kpi_metric_card.dart';
import 'package:practi_horas_app/features/dashboard/presentation/widgets/organisms/chart_semanal.dart';
import 'package:practi_horas_app/features/dashboard/presentation/widgets/organisms/horario_hoy_card.dart';
import 'package:practi_horas_app/features/dashboard/presentation/widgets/organisms/jornadas_recientes_card.dart';
import 'package:practi_horas_app/features/dashboard/presentation/widgets/organisms/progress_bar_meta.dart';
import 'package:practi_horas_app/features/dashboard/presentation/widgets/organisms/ritmo_status_card.dart';

class DashboardScreen extends ConsumerWidget {
  final VoidCallback onNavigateToRegistrar;
  final VoidCallback onNavigateToHistorial;
  final VoidCallback? onNavigateToAjustes;

  const DashboardScreen({
    super.key,
    required this.onNavigateToRegistrar,
    required this.onNavigateToHistorial,
    this.onNavigateToAjustes,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricasAsync = ref.watch(dashboardMetricsProvider);
    final perfilAsync = ref.watch(perfilNotifierProvider);
    final registrosAsync = ref.watch(registrosNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final today = DateTime.now();
    final diaSemanaKey = DateFormatters.getDiaSemanaKey(today);

    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(
          duration: const Duration(milliseconds: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                perfilAsync.maybeWhen(
                  data: (p) => '¡Hola, ${p.nombre}!',
                  orElse: () => '¡Hola, Practicante!',
                ),
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                DateFormatters.fechaCompleta(today),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FadeIn(
              duration: const Duration(milliseconds: 500),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.timer_outlined,
                        color: Color(0xFF4F46E5),
                        size: 20,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: metricasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (metricas) {
          final perfil = perfilAsync.value;
          final horarioHoy = perfil?.horarioSemanal[diaSemanaKey];

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(registrosNotifierProvider);
              ref.invalidate(perfilNotifierProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeInDown(
                    duration: const Duration(milliseconds: 500),
                    child: ProgressBarMeta(
                      horasCompletadas: metricas.horasTotalesCompletadas,
                      metaHoras: metricas.metaHorasTotal,
                      porcentaje: metricas.porcentajeProgreso,
                      horasRestantes: metricas.horasRestantes,
                    ),
                  ),
                  const SizedBox(height: 14),
                  RitmoStatusCard(
                    metricas: metricas,
                    onConfigurarFechas: onNavigateToAjustes,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: KpiMetricCard(
                          title: 'Esta Semana',
                          value: '${metricas.horasEstaSemana}h',
                          subtitle: 'de ${perfil?.minimoHorasSemana ?? 0}h meta sem.',
                          icon: Icons.date_range_rounded,
                          accentColor: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: KpiMetricCard(
                          title: 'Total Días',
                          value: '${metricas.totalDiasTrabajados}',
                          subtitle: 'jornadas hechas',
                          icon: Icons.check_circle_outline_rounded,
                          accentColor: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ChartSemanal(
                    horasPorDiaSemana: metricas.horasPorDiaSemana,
                    horasEstaSemana: metricas.horasEstaSemana,
                  ),
                  const SizedBox(height: 14),
                  HorarioHoyCard(
                    horarioHoy: horarioHoy,
                    onEditarHorario: onNavigateToAjustes,
                  ),
                  const SizedBox(height: 14),
                  registrosAsync.when(
                    data: (registros) => JornadasRecientesCard(
                      registros: registros,
                      onVerHistorial: onNavigateToHistorial,
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

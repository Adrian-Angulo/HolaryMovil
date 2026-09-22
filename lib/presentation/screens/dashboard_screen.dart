import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/utils/date_formatters.dart';
import '../../domain/entities/registro_hora.dart';
import '../providers/dashboard_provider.dart';
import '../providers/perfil_provider.dart';
import '../providers/registro_provider.dart';
import '../widgets/common/custom_card.dart';
import '../widgets/dashboard/chart_semanal.dart';
import '../widgets/dashboard/kpi_card.dart';
import '../widgets/dashboard/progress_bar_meta.dart';
import '../widgets/dashboard/ritmo_status_card.dart';

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
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
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
                  // 1. Tarjeta Principal con Meta y Progreso (Animación Suave)
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

                  // 2. Tarjeta de Estrategia de Ritmo / Cumplimiento
                  RitmoStatusCard(
                    metricas: metricas,
                    onConfigurarFechas: onNavigateToAjustes,
                  ),
                  const SizedBox(height: 14),

                  // 3. Tarjetas KPI en Grid con Entrada Escalonada
                  Row(
                    children: [
                      Expanded(
                        child: FadeInLeft(
                          duration: const Duration(milliseconds: 450),
                          delay: const Duration(milliseconds: 100),
                          child: KpiCard(
                            title: 'Esta Semana',
                            value: '${metricas.horasEstaSemana}h',
                            subtitle: 'Lunes a Domingo',
                            icon: Icons.calendar_view_week_rounded,
                            iconColor: const Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FadeInRight(
                          duration: const Duration(milliseconds: 450),
                          delay: const Duration(milliseconds: 150),
                          child: KpiCard(
                            title: 'Este Mes',
                            value: '${metricas.horasEsteMes}h',
                            subtitle: 'Acumulado mensual',
                            icon: Icons.calendar_month_rounded,
                            iconColor: const Color(0xFF06B6D4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FadeInLeft(
                          duration: const Duration(milliseconds: 450),
                          delay: const Duration(milliseconds: 200),
                          child: KpiCard(
                            title: 'Días Registrados',
                            value: '${metricas.totalDiasTrabajados}',
                            subtitle: 'Jornadas completas',
                            icon: Icons.event_available_rounded,
                            iconColor: const Color(0xFF10B981),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FadeInRight(
                          duration: const Duration(milliseconds: 450),
                          delay: const Duration(milliseconds: 250),
                          child: KpiCard(
                            title: 'Promedio Diario',
                            value: '${metricas.promedioHorasPorDia}h',
                            subtitle: 'Por día trabajado',
                            icon: Icons.av_timer_rounded,
                            iconColor: const Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 4. Gráfica Semanal con fl_chart
                  FadeInUp(
                    duration: const Duration(milliseconds: 500),
                    delay: const Duration(milliseconds: 300),
                    child: ChartSemanal(
                      horasPorDiaSemana: metricas.horasPorDiaSemana,
                      horasEstaSemana: metricas.horasEstaSemana,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Horario Programado para Hoy
                  if (horarioHoy != null)
                    FadeInUp(
                      duration: const Duration(milliseconds: 500),
                      delay: const Duration(milliseconds: 350),
                      child: CustomCard(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: horarioHoy.activo
                                    ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                    : const Color(0xFF64748B).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                horarioHoy.activo ? Icons.work_rounded : Icons.weekend_rounded,
                                color: horarioHoy.activo ? const Color(0xFF10B981) : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Horario para Hoy (${DateFormatters.getDiaNombre(diaSemanaKey)})',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    horarioHoy.activo
                                        ? '${horarioHoy.horaInicio} - ${horarioHoy.horaFin} (${horarioHoy.modalidad})'
                                        : 'Día no laboral según tu horario configurado',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (horarioHoy.activo)
                              FilledButton.tonal(
                                onPressed: onNavigateToRegistrar,
                                child: const Text('Registrar'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 6. Últimos Registros
                  FadeIn(
                    duration: const Duration(milliseconds: 400),
                    delay: const Duration(milliseconds: 400),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Últimas Jornadas',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton(
                          onPressed: onNavigateToHistorial,
                          child: const Text('Ver todas'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  registrosAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error al cargar jornadas: $e'),
                    data: (registros) {
                      if (registros.isEmpty) {
                        return FadeInUp(
                          duration: const Duration(milliseconds: 450),
                          delay: const Duration(milliseconds: 450),
                          child: CustomCard(
                            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.note_alt_outlined, size: 40, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Aún no has registrado ninguna jornada',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: onNavigateToRegistrar,
                                    icon: const Icon(Icons.add, size: 18),
                                    label: const Text('Registrar Primera Jornada'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      final ultimos = registros.take(3).toList();
                      return Column(
                        children: List.generate(ultimos.length, (index) {
                          final reg = ultimos[index];
                          return FadeInUp(
                            duration: const Duration(milliseconds: 400),
                            delay: Duration(milliseconds: 400 + (index * 80)),
                            child: _buildRegistroSummaryTile(context, reg),
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRegistroSummaryTile(BuildContext context, RegistroHora reg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CustomCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.access_time_filled, color: Color(0xFF4F46E5), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormatters.fechaCompleta(reg.fecha),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${reg.horaInicio} - ${reg.horaFin} • ${reg.modalidad}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${reg.horasComputables}h',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

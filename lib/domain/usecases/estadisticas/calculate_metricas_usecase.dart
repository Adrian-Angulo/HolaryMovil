import '../../entities/metricas_dashboard.dart';
import '../../entities/perfil.dart';
import '../../entities/registro_hora.dart';

class CalculateMetricasUseCase {
  MetricasDashboard execute({
    required List<RegistroHora> registros,
    required Perfil perfil,
    DateTime? fechaReferencia,
  }) {
    final now = fechaReferencia ?? DateTime.now();

    // 1. Horas totales completadas
    double horasTotales = 0.0;
    for (final reg in registros) {
      horasTotales += reg.horasComputables;
    }
    horasTotales = double.parse(horasTotales.toStringAsFixed(2));

    // 2. Meta y Restantes
    final meta = perfil.metaHorasTotal;
    final horasRestantes = (meta - horasTotales) > 0
        ? double.parse((meta - horasTotales).toStringAsFixed(2))
        : 0.0;

    final porcentaje = meta > 0
        ? ((horasTotales / meta) * 100.0).clamp(0.0, 100.0)
        : 0.0;

    // 3. Rango de la semana actual (Lunes a Domingo)
    final lunes = now.subtract(Duration(days: now.weekday - 1));
    final inicioSemana = DateTime(lunes.year, lunes.month, lunes.day, 0, 0, 0);
    final finSemana = inicioSemana.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    // 4. Rango del mes actual
    final inicioMes = DateTime(now.year, now.month, 1, 0, 0, 0);
    final finMes = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    double horasSemana = 0.0;
    double horasMes = 0.0;
    final Map<int, double> horasPorDia = {
      1: 0.0, // Lunes
      2: 0.0, // Martes
      3: 0.0, // Miércoles
      4: 0.0, // Jueves
      5: 0.0, // Viernes
      6: 0.0, // Sábado
      7: 0.0, // Domingo
    };

    final Set<String> fechasUnicasTrabajadas = {};

    for (final reg in registros) {
      final fecha = reg.fecha;
      final keyFecha = '${fecha.year}-${fecha.month}-${fecha.day}';
      fechasUnicasTrabajadas.add(keyFecha);

      // En esta semana
      if (fecha.isAfter(inicioSemana.subtract(const Duration(seconds: 1))) &&
          fecha.isBefore(finSemana.add(const Duration(seconds: 1)))) {
        horasSemana += reg.horasComputables;
        final diaIndex = fecha.weekday; // 1 (Mon) .. 7 (Sun)
        horasPorDia[diaIndex] = double.parse(
          ((horasPorDia[diaIndex] ?? 0.0) + reg.horasComputables).toStringAsFixed(2),
        );
      }

      // En este mes
      if (fecha.isAfter(inicioMes.subtract(const Duration(seconds: 1))) &&
          fecha.isBefore(finMes.add(const Duration(seconds: 1)))) {
        horasMes += reg.horasComputables;
      }
    }

    final totalDias = fechasUnicasTrabajadas.length;
    final promedioDiario = totalDias > 0
        ? double.parse((horasTotales / totalDias).toStringAsFixed(2))
        : 0.0;

    return MetricasDashboard(
      horasTotalesCompletadas: horasTotales,
      metaHorasTotal: meta,
      horasRestantes: horasRestantes,
      porcentajeProgreso: double.parse(porcentaje.toStringAsFixed(1)),
      horasEstaSemana: double.parse(horasSemana.toStringAsFixed(2)),
      horasEsteMes: double.parse(horasMes.toStringAsFixed(2)),
      totalDiasTrabajados: totalDias,
      promedioHorasPorDia: promedioDiario,
      horasPorDiaSemana: horasPorDia,
    );
  }
}

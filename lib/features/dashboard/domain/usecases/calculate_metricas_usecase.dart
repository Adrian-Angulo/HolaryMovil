import '../../../perfil/domain/entities/perfil.dart';
import '../../../registros/domain/entities/registro_hora.dart';
import '../entities/metricas_dashboard.dart';

class CalculateMetricasUseCase {
  MetricasDashboard execute({
    required List<RegistroHora> registros,
    required Perfil perfil,
    DateTime? fechaReferencia,
  }) => call(
    registros: registros,
    perfil: perfil,
    fechaReferencia: fechaReferencia,
  );

  MetricasDashboard call({
    required List<RegistroHora> registros,
    required Perfil perfil,
    DateTime? fechaReferencia,
  }) {
    final now = fechaReferencia ?? DateTime.now();

    // 1. Horas registradas en la app y horas totales (incluye horas previas cursadas)
    double horasRegistradas = 0.0;
    for (final reg in registros) {
      horasRegistradas += reg.horasComputables;
    }
    horasRegistradas = double.parse(horasRegistradas.toStringAsFixed(2));

    final double horasPrevias = perfil.horasInicialesPrevias;
    double horasTotales = double.parse((horasPrevias + horasRegistradas).toStringAsFixed(2));

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
        ? double.parse((horasRegistradas / totalDias).toStringAsFixed(2))
        : 0.0;

    // 5. Estrategia de Ritmo y Cumplimiento de Horas
    EstadoRitmo estadoRitmo = EstadoRitmo.sinFechas;
    double diferenciaHorasRitmo = 0.0;
    double horasEsperadasHoy = 0.0;
    double ritmoDiarioSugerido = 0.0;
    int diasHabilesRestantes = 0;
    String mensajeRitmo = '';

    if (perfil.fechaInicio != null && perfil.fechaFin != null) {
      final fInicio = DateTime(perfil.fechaInicio!.year, perfil.fechaInicio!.month, perfil.fechaInicio!.day);
      final fFin = DateTime(perfil.fechaFin!.year, perfil.fechaFin!.month, perfil.fechaFin!.day, 23, 59, 59);
      final fHoy = DateTime(now.year, now.month, now.day);

      final Set<int> diasLaboralesWeekdays = {};
      const diasKeys = ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'];
      for (int i = 0; i < diasKeys.length; i++) {
        final key = diasKeys[i];
        final hDia = perfil.horarioSemanal[key];
        if (hDia?.activo == true) {
          diasLaboralesWeekdays.add(i + 1);
        }
      }
      if (diasLaboralesWeekdays.isEmpty) {
        diasLaboralesWeekdays.addAll([1, 2, 3, 4, 5]);
      }

      int totalDiasHabiles = 0;
      int diasHabilesTranscurridos = 0;
      int diasRestantes = 0;

      DateTime iter = fInicio;
      while (iter.isBefore(fFin) || iter.isAtSameMomentAs(fFin)) {
        if (diasLaboralesWeekdays.contains(iter.weekday)) {
          totalDiasHabiles++;
          if (iter.isBefore(fHoy) || iter.isAtSameMomentAs(fHoy)) {
            diasHabilesTranscurridos++;
          }
          if (iter.isAfter(fHoy)) {
            diasRestantes++;
          }
        }
        iter = iter.add(const Duration(days: 1));
      }

      diasHabilesRestantes = diasRestantes;

      if (totalDiasHabiles > 0) {
        horasEsperadasHoy = double.parse(
          (meta * (diasHabilesTranscurridos / totalDiasHabiles)).toStringAsFixed(2),
        );
        diferenciaHorasRitmo = double.parse((horasTotales - horasEsperadasHoy).toStringAsFixed(2));

        if (diasHabilesRestantes > 0) {
          ritmoDiarioSugerido = double.parse((horasRestantes / diasHabilesRestantes).toStringAsFixed(2));
        } else {
          ritmoDiarioSugerido = horasRestantes;
        }

        if (horasRestantes <= 0) {
          estadoRitmo = EstadoRitmo.adelantado;
          mensajeRitmo = '🎉 ¡Completaste el 100% de tus horas de prácticas!';
        } else if (diferenciaHorasRitmo >= 3.0) {
          estadoRitmo = EstadoRitmo.adelantado;
          mensajeRitmo = '🚀 Vas adelantado por ${diferenciaHorasRitmo.toStringAsFixed(1)} hrs. ¡Excelente ritmo!';
        } else if (diferenciaHorasRitmo >= -3.0 && diferenciaHorasRitmo < 3.0) {
          estadoRitmo = EstadoRitmo.aTiempo;
          mensajeRitmo = '✨ Vas al día con tu meta. Mantén este ritmo.';
        } else {
          estadoRitmo = EstadoRitmo.atrasado;
          final atraso = diferenciaHorasRitmo.abs().toStringAsFixed(1);
          mensajeRitmo = '⏳ Vas atrasado por $atraso hrs. Necesitas hacer $ritmoDiarioSugerido hrs/día para terminar a tiempo.';
        }
      } else {
        estadoRitmo = EstadoRitmo.sinFechas;
        mensajeRitmo = 'Revisa las fechas configuradas de inicio y fin.';
      }
    } else {
      estadoRitmo = EstadoRitmo.sinFechas;
      mensajeRitmo = 'Configura las fechas de tus prácticas para ver tu ritmo.';
    }

    return MetricasDashboard(
      horasTotalesCompletadas: horasTotales,
      horasPreviasCursadas: horasPrevias,
      horasRegistradasEnApp: horasRegistradas,
      metaHorasTotal: meta,
      horasRestantes: horasRestantes,
      porcentajeProgreso: double.parse(porcentaje.toStringAsFixed(1)),
      horasEstaSemana: double.parse(horasSemana.toStringAsFixed(2)),
      horasEsteMes: double.parse(horasMes.toStringAsFixed(2)),
      totalDiasTrabajados: totalDias,
      promedioHorasPorDia: promedioDiario,
      horasPorDiaSemana: horasPorDia,
      estadoRitmo: estadoRitmo,
      diferenciaHorasRitmo: diferenciaHorasRitmo,
      horasEsperadasHoy: horasEsperadasHoy,
      ritmoDiarioSugerido: ritmoDiarioSugerido,
      diasHabilesRestantes: diasHabilesRestantes,
      mensajeRitmo: mensajeRitmo,
    );
  }
}

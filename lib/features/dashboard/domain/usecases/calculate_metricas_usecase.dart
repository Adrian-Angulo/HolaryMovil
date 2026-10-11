import '../../../perfil/domain/entities/perfil.dart';
import '../../../registros/domain/entities/registro_hora.dart';
import '../entities/metricas_dashboard.dart';

class CalendarioHabiles {
  final int totalDiasHabiles;
  final int diasHabilesCerrados;
  final bool esHoyHabil;
  final int diasHabilesFuturos;

  const CalendarioHabiles({
    required this.totalDiasHabiles,
    required this.diasHabilesCerrados,
    required this.esHoyHabil,
    required this.diasHabilesFuturos,
  });
}

class HorasAgrupadas {
  final double horasRegistradas;
  final double horasRegistradasHoy;
  final double horasSemana;
  final double horasMes;
  final int totalDiasTrabajados;
  final Map<int, double> horasPorDiaSemana;

  const HorasAgrupadas({
    required this.horasRegistradas,
    required this.horasRegistradasHoy,
    required this.horasSemana,
    required this.horasMes,
    required this.totalDiasTrabajados,
    required this.horasPorDiaSemana,
  });
}

class CalculateMetricasUseCase {
  static const double umbralToleranciaHoras = 3.0;
  static const double jornadaMaximaHabitual = 6.0;

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

    final agrupacion = _calcularHorasAgrupadas(registros, now);
    final horasRegistradas = agrupacion.horasRegistradas;
    final horasPrevias = perfil.horasInicialesPrevias;
    final horasTotales = _redondear(horasPrevias + horasRegistradas, 2);

    final meta = perfil.metaHorasTotal;
    final horasRestantes = (meta - horasTotales) > 0
        ? _redondear(meta - horasTotales, 2)
        : 0.0;

    final porcentaje = meta > 0
        ? ((horasTotales / meta) * 100.0).clamp(0.0, 100.0)
        : 0.0;

    final promedioDiario = agrupacion.totalDiasTrabajados > 0
        ? _redondear(horasRegistradas / agrupacion.totalDiasTrabajados, 2)
        : 0.0;

    // Estrategia de Ritmo y Cumplimiento de Horas
    EstadoRitmo estadoRitmo = EstadoRitmo.sinFechas;
    double diferenciaHorasRitmo = 0.0;
    double horasEsperadasHoy = 0.0;
    double ritmoDiarioSugerido = 0.0;
    int diasHabilesRestantes = 0;
    String mensajeRitmo = 'Configura las fechas de tus prácticas para ver tu ritmo.';

    if (perfil.fechaInicio != null && perfil.fechaFin != null) {
      final fInicio = DateTime(perfil.fechaInicio!.year, perfil.fechaInicio!.month, perfil.fechaInicio!.day);
      final fFin = DateTime(perfil.fechaFin!.year, perfil.fechaFin!.month, perfil.fechaFin!.day, 23, 59, 59);
      final fHoy = DateTime(now.year, now.month, now.day);

      final calendario = _calcularCalendarioHabiles(perfil, fInicio, fFin, fHoy);
      final totalDiasHabiles = calendario.totalDiasHabiles;
      final diasHabilesCerrados = calendario.diasHabilesCerrados;
      final esHoyHabil = calendario.esHoyHabil;
      final diasHabilesFuturos = calendario.diasHabilesFuturos;

      // Días hábiles disponibles futuros para cumplir las horas pendientes:
      // Si hoy ya se registraron horas (jornada ejecutada), las horas restantes corresponden a los días futuros.
      // Si hoy es hábil pero aún no se registran horas, hoy sigue disponible para aportar trabajo.
      if (fHoy.isAfter(fFin)) {
        diasHabilesRestantes = 0;
      } else if (fHoy.isBefore(fInicio)) {
        diasHabilesRestantes = totalDiasHabiles;
      } else {
        final hoyDisponible = (esHoyHabil && agrupacion.horasRegistradasHoy == 0.0) ? 1 : 0;
        diasHabilesRestantes = hoyDisponible + diasHabilesFuturos;
      }

      // Horas esperadas acumuladas:
      // Para evitar el efecto intra-día: si hoy ya registró horas, evaluamos contra el cierre de hoy.
      // Si hoy aún no registra horas, evaluamos contra el inicio del turno de hoy (días cerrados).
      final diasEvaluados = (esHoyHabil && agrupacion.horasRegistradasHoy > 0.0)
          ? diasHabilesCerrados + 1
          : diasHabilesCerrados;

      horasEsperadasHoy = totalDiasHabiles > 0
          ? _redondear(meta * (diasEvaluados / totalDiasHabiles), 1)
          : 0.0;

      diferenciaHorasRitmo = _redondear(horasTotales - horasEsperadasHoy, 1);

      if (horasRestantes <= 0) {
        estadoRitmo = EstadoRitmo.adelantado;
        ritmoDiarioSugerido = 0.0;
        mensajeRitmo = '🎉 ¡Completaste el 100% de tus horas de prácticas!';
      } else if (fHoy.isAfter(fFin) || diasHabilesRestantes == 0) {
        estadoRitmo = EstadoRitmo.vencido;
        ritmoDiarioSugerido = 0.0;
        mensajeRitmo =
            '📅 El periodo de prácticas finalizó con ${horasRestantes.toStringAsFixed(1)} hrs pendientes. Ajusta tu fecha de fin si acordaste una extensión.';
      } else if (fHoy.isBefore(fInicio)) {
        estadoRitmo = EstadoRitmo.aTiempo;
        ritmoDiarioSugerido = totalDiasHabiles > 0
            ? _redondear(horasRestantes / totalDiasHabiles, 1)
            : 0.0;
        final fechaStr = '${fInicio.year}-${fInicio.month.toString().padLeft(2, '0')}-${fInicio.day.toString().padLeft(2, '0')}';
        mensajeRitmo = '📅 Tu periodo de prácticas inicia el $fechaStr. Ritmo planificado: ${ritmoDiarioSugerido.toStringAsFixed(1)} hrs/día.';
      } else {
        ritmoDiarioSugerido = diasHabilesRestantes > 0
            ? _redondear(horasRestantes / diasHabilesRestantes, 1)
            : horasRestantes;

        if (diferenciaHorasRitmo >= umbralToleranciaHoras) {
          estadoRitmo = EstadoRitmo.adelantado;
          mensajeRitmo = '🚀 Vas adelantado por +${diferenciaHorasRitmo.toStringAsFixed(1)} hrs. ¡Excelente ritmo!';
        } else if (diferenciaHorasRitmo >= -umbralToleranciaHoras) {
          estadoRitmo = EstadoRitmo.aTiempo;
          mensajeRitmo = '✨ Vas al día según tu planificación.';
        } else {
          estadoRitmo = EstadoRitmo.atrasado;
          final atraso = diferenciaHorasRitmo.abs().toStringAsFixed(1);
          final ritmoStr = ritmoDiarioSugerido.toStringAsFixed(1);
          if (ritmoDiarioSugerido > jornadaMaximaHabitual) {
            mensajeRitmo =
                '⚠️ Llevas un retraso de $atraso hrs. Necesitas hacer $ritmoStr hrs/día (excede la jornada habitual de 6h). Considera tramitar una extensión de fecha fin.';
          } else {
            mensajeRitmo =
                '⚠️ Llevas un retraso de $atraso hrs. Necesitas hacer $ritmoStr hrs/día para terminar a tiempo.';
          }
        }
      }
    }

    return MetricasDashboard(
      horasTotalesCompletadas: horasTotales,
      horasPreviasCursadas: horasPrevias,
      horasRegistradasEnApp: horasRegistradas,
      metaHorasTotal: meta,
      horasRestantes: horasRestantes,
      porcentajeProgreso: _redondear(porcentaje, 1),
      horasEstaSemana: agrupacion.horasSemana,
      horasEsteMes: agrupacion.horasMes,
      totalDiasTrabajados: agrupacion.totalDiasTrabajados,
      promedioHorasPorDia: promedioDiario,
      horasPorDiaSemana: agrupacion.horasPorDiaSemana,
      estadoRitmo: estadoRitmo,
      diferenciaHorasRitmo: diferenciaHorasRitmo,
      horasEsperadasHoy: horasEsperadasHoy,
      ritmoDiarioSugerido: ritmoDiarioSugerido,
      diasHabilesRestantes: diasHabilesRestantes,
      mensajeRitmo: mensajeRitmo,
    );
  }

  CalendarioHabiles _calcularCalendarioHabiles(
    Perfil perfil,
    DateTime fInicio,
    DateTime fFin,
    DateTime fHoy,
  ) {
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
    int diasHabilesCerrados = 0;
    bool esHoyHabil = false;
    int diasHabilesFuturos = 0;

    DateTime iter = fInicio;
    while (iter.isBefore(fFin) || iter.isAtSameMomentAs(fFin)) {
      if (diasLaboralesWeekdays.contains(iter.weekday)) {
        totalDiasHabiles++;
        final fIter = DateTime(iter.year, iter.month, iter.day);

        if (fIter.isBefore(fHoy)) {
          diasHabilesCerrados++;
        } else if (fIter.isAtSameMomentAs(fHoy)) {
          esHoyHabil = true;
        } else {
          diasHabilesFuturos++;
        }
      }
      iter = iter.add(const Duration(days: 1));
    }

    return CalendarioHabiles(
      totalDiasHabiles: totalDiasHabiles,
      diasHabilesCerrados: diasHabilesCerrados,
      esHoyHabil: esHoyHabil,
      diasHabilesFuturos: diasHabilesFuturos,
    );
  }

  HorasAgrupadas _calcularHorasAgrupadas(List<RegistroHora> registros, DateTime now) {
    final lunes = now.subtract(Duration(days: now.weekday - 1));
    final inicioSemana = DateTime(lunes.year, lunes.month, lunes.day, 0, 0, 0);
    final finSemana = inicioSemana.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

    final inicioMes = DateTime(now.year, now.month, 1, 0, 0, 0);
    final finMes = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final fHoy = DateTime(now.year, now.month, now.day);

    double horasRegistradas = 0.0;
    double horasRegistradasHoy = 0.0;
    double horasSemana = 0.0;
    double horasMes = 0.0;
    final Map<int, double> horasPorDia = {
      1: 0.0,
      2: 0.0,
      3: 0.0,
      4: 0.0,
      5: 0.0,
      6: 0.0,
      7: 0.0,
    };
    final Set<String> fechasUnicasTrabajadas = {};

    for (final reg in registros) {
      final horas = reg.horasComputables;
      horasRegistradas += horas;

      final fecha = reg.fecha;
      final fReg = DateTime(fecha.year, fecha.month, fecha.day);
      final keyFecha = '${fecha.year}-${fecha.month}-${fecha.day}';
      fechasUnicasTrabajadas.add(keyFecha);

      if (fReg.isAtSameMomentAs(fHoy)) {
        horasRegistradasHoy += horas;
      }

      if (fecha.isAfter(inicioSemana.subtract(const Duration(seconds: 1))) &&
          fecha.isBefore(finSemana.add(const Duration(seconds: 1)))) {
        horasSemana += horas;
        final diaIndex = fecha.weekday;
        horasPorDia[diaIndex] = _redondear(
          (horasPorDia[diaIndex] ?? 0.0) + horas,
          2,
        );
      }

      if (fecha.isAfter(inicioMes.subtract(const Duration(seconds: 1))) &&
          fecha.isBefore(finMes.add(const Duration(seconds: 1)))) {
        horasMes += horas;
      }
    }

    return HorasAgrupadas(
      horasRegistradas: _redondear(horasRegistradas, 2),
      horasRegistradasHoy: _redondear(horasRegistradasHoy, 2),
      horasSemana: _redondear(horasSemana, 2),
      horasMes: _redondear(horasMes, 2),
      totalDiasTrabajados: fechasUnicasTrabajadas.length,
      horasPorDiaSemana: horasPorDia,
    );
  }

  double _redondear(double valor, int decimales) {
    return double.parse(valor.toStringAsFixed(decimales));
  }
}

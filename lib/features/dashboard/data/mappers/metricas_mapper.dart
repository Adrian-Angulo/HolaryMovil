import '../../domain/entities/metricas_dashboard.dart';
import '../models/metricas_dashboard_api_model.dart';

class MetricasMapper {
  static EstadoRitmo _parseEstado(String estadoStr) {
    switch (estadoStr.toLowerCase()) {
      case 'adelantado':
        return EstadoRitmo.adelantado;
      case 'a_tiempo':
      case 'atiempo':
        return EstadoRitmo.aTiempo;
      case 'atrasado':
        return EstadoRitmo.atrasado;
      case 'sin_fechas':
      case 'sinfechas':
      default:
        return EstadoRitmo.sinFechas;
    }
  }

  static MetricasDashboard toDomain(MetricasDashboardApiModel model) {
    final Map<int, double> horasDia = {
      1: model.horasPorDiaSemana['1'] ?? 0.0,
      2: model.horasPorDiaSemana['2'] ?? 0.0,
      3: model.horasPorDiaSemana['3'] ?? 0.0,
      4: model.horasPorDiaSemana['4'] ?? 0.0,
      5: model.horasPorDiaSemana['5'] ?? 0.0,
      6: model.horasPorDiaSemana['6'] ?? 0.0,
      7: model.horasPorDiaSemana['7'] ?? 0.0,
    };

    return MetricasDashboard(
      horasTotalesCompletadas: model.horasTotalesCompletadas,
      horasPreviasCursadas: model.horasPreviasCursadas,
      horasRegistradasEnApp: model.horasRegistradasEnApp,
      metaHorasTotal: model.metaHorasTotal,
      horasRestantes: model.horasRestantes,
      porcentajeProgreso: model.porcentajeProgreso,
      horasEstaSemana: model.horasEstaSemana,
      horasEsteMes: model.horasEsteMes,
      totalDiasTrabajados: model.totalDiasTrabajados,
      promedioHorasPorDia: model.promedioHorasPorDia,
      horasPorDiaSemana: horasDia,
      estadoRitmo: _parseEstado(model.estadoRitmo),
      diferenciaHorasRitmo: model.diferenciaHorasRitmo,
      horasEsperadasHoy: model.horasEsperadasHoy,
      ritmoDiarioSugerido: model.ritmoDiarioSugerido,
      diasHabilesRestantes: model.diasHabilesRestantes,
      mensajeRitmo: model.mensajeRitmo,
    );
  }
}

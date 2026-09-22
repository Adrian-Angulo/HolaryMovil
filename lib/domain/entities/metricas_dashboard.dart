enum EstadoRitmo {
  adelantado,
  aTiempo,
  atrasado,
  sinFechas,
}

class MetricasDashboard {
  final double horasTotalesCompletadas;
  final double horasPreviasCursadas;
  final double horasRegistradasEnApp;
  final double metaHorasTotal;
  final double horasRestantes;
  final double porcentajeProgreso; // 0.0 a 100.0
  final double horasEstaSemana;
  final double horasEsteMes;
  final int totalDiasTrabajados;
  final double promedioHorasPorDia;
  final Map<int, double> horasPorDiaSemana; // 1 (Lun) a 7 (Dom) -> horas

  // Estrategia de Ritmo y Cumplimiento
  final EstadoRitmo estadoRitmo;
  final double diferenciaHorasRitmo; // Positivo = adelantado, Negativo = atrasado
  final double horasEsperadasHoy;
  final double ritmoDiarioSugerido; // Horas recomendadas por día hábil restante
  final int diasHabilesRestantes;
  final String mensajeRitmo;

  const MetricasDashboard({
    required this.horasTotalesCompletadas,
    required this.horasPreviasCursadas,
    required this.horasRegistradasEnApp,
    required this.metaHorasTotal,
    required this.horasRestantes,
    required this.porcentajeProgreso,
    required this.horasEstaSemana,
    required this.horasEsteMes,
    required this.totalDiasTrabajados,
    required this.promedioHorasPorDia,
    required this.horasPorDiaSemana,
    required this.estadoRitmo,
    required this.diferenciaHorasRitmo,
    required this.horasEsperadasHoy,
    required this.ritmoDiarioSugerido,
    required this.diasHabilesRestantes,
    required this.mensajeRitmo,
  });

  factory MetricasDashboard.initial() {
    return const MetricasDashboard(
      horasTotalesCompletadas: 0.0,
      horasPreviasCursadas: 0.0,
      horasRegistradasEnApp: 0.0,
      metaHorasTotal: 360.0,
      horasRestantes: 360.0,
      porcentajeProgreso: 0.0,
      horasEstaSemana: 0.0,
      horasEsteMes: 0.0,
      totalDiasTrabajados: 0,
      promedioHorasPorDia: 0.0,
      horasPorDiaSemana: {1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0, 5: 0.0, 6: 0.0, 7: 0.0},
      estadoRitmo: EstadoRitmo.sinFechas,
      diferenciaHorasRitmo: 0.0,
      horasEsperadasHoy: 0.0,
      ritmoDiarioSugerido: 0.0,
      diasHabilesRestantes: 0,
      mensajeRitmo: 'Configura tus fechas de inicio y fin para ver tu ritmo',
    );
  }
}

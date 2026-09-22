class MetricasDashboard {
  final double horasTotalesCompletadas;
  final double metaHorasTotal;
  final double horasRestantes;
  final double porcentajeProgreso; // 0.0 a 100.0
  final double horasEstaSemana;
  final double horasEsteMes;
  final int totalDiasTrabajados;
  final double promedioHorasPorDia;
  final Map<int, double> horasPorDiaSemana; // 1 (Lun) a 7 (Dom) -> horas

  const MetricasDashboard({
    required this.horasTotalesCompletadas,
    required this.metaHorasTotal,
    required this.horasRestantes,
    required this.porcentajeProgreso,
    required this.horasEstaSemana,
    required this.horasEsteMes,
    required this.totalDiasTrabajados,
    required this.promedioHorasPorDia,
    required this.horasPorDiaSemana,
  });

  factory MetricasDashboard.initial() {
    return const MetricasDashboard(
      horasTotalesCompletadas: 0.0,
      metaHorasTotal: 360.0,
      horasRestantes: 360.0,
      porcentajeProgreso: 0.0,
      horasEstaSemana: 0.0,
      horasEsteMes: 0.0,
      totalDiasTrabajados: 0,
      promedioHorasPorDia: 0.0,
      horasPorDiaSemana: {1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0, 5: 0.0, 6: 0.0, 7: 0.0},
    );
  }
}

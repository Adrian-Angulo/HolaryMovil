class MetricasDashboardApiModel {
  final double horasTotalesCompletadas;
  final double horasPreviasCursadas;
  final double horasRegistradasEnApp;
  final double metaHorasTotal;
  final double horasRestantes;
  final double porcentajeProgreso;
  final double horasEstaSemana;
  final double horasEsteMes;
  final int totalDiasTrabajados;
  final double promedioHorasPorDia;
  final Map<String, double> horasPorDiaSemana;
  final String estadoRitmo;
  final double diferenciaHorasRitmo;
  final double horasEsperadasHoy;
  final double ritmoDiarioSugerido;
  final int diasHabilesRestantes;
  final String mensajeRitmo;

  const MetricasDashboardApiModel({
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

  factory MetricasDashboardApiModel.fromJson(Map<String, dynamic> json) {
    // Soportar respuesta envuelta en data o directa
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

    final horasDiaRaw = data['horasPorDiaSemana'];
    final horasDiaMap = <String, double>{};
    if (horasDiaRaw is Map<String, dynamic>) {
      horasDiaRaw.forEach((k, v) {
        horasDiaMap[k] = (v ?? 0.0).toDouble();
      });
    }

    return MetricasDashboardApiModel(
      horasTotalesCompletadas: (data['horasTotalesCompletadas'] ?? 0.0).toDouble(),
      horasPreviasCursadas: (data['horasPreviasCursadas'] ?? 0.0).toDouble(),
      horasRegistradasEnApp: (data['horasRegistradasEnApp'] ?? 0.0).toDouble(),
      metaHorasTotal: (data['metaHorasTotal'] ?? 360.0).toDouble(),
      horasRestantes: (data['horasRestantes'] ?? 0.0).toDouble(),
      porcentajeProgreso: (data['porcentajeProgreso'] ?? 0.0).toDouble(),
      horasEstaSemana: (data['horasEstaSemana'] ?? 0.0).toDouble(),
      horasEsteMes: (data['horasEsteMes'] ?? 0.0).toDouble(),
      totalDiasTrabajados: (data['totalDiasTrabajados'] ?? 0) as int,
      promedioHorasPorDia: (data['promedioHorasPorDia'] ?? 0.0).toDouble(),
      horasPorDiaSemana: horasDiaMap,
      estadoRitmo: data['estadoRitmo']?.toString() ?? 'sin_fechas',
      diferenciaHorasRitmo: (data['diferenciaHorasRitmo'] ?? 0.0).toDouble(),
      horasEsperadasHoy: (data['horasEsperadasHoy'] ?? 0.0).toDouble(),
      ritmoDiarioSugerido: (data['ritmoDiarioSugerido'] ?? 0.0).toDouble(),
      diasHabilesRestantes: (data['diasHabilesRestantes'] ?? 0) as int,
      mensajeRitmo: data['mensajeRitmo']?.toString() ?? '',
    );
  }
}

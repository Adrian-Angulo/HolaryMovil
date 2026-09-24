class RegistroHora {
  final String id;
  final DateTime fecha;
  final String horaInicio; // "08:00"
  final String horaFin;    // "13:00"
  final int descuentoAlmuerzoMinutos;
  final double horasComputables;
  final String modalidad; // "Presencial", "Remoto"
  final String actividades;
  final DateTime createdAt;

  const RegistroHora({
    required this.id,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.descuentoAlmuerzoMinutos,
    required this.horasComputables,
    required this.modalidad,
    required this.actividades,
    required this.createdAt,
  });

  String get horaEntrada => horaInicio;
  String get horaSalida => horaFin;
  double get horasCalculadas => horasComputables;

  RegistroHora copyWith({
    String? id,
    DateTime? fecha,
    String? horaInicio,
    String? horaFin,
    int? descuentoAlmuerzoMinutos,
    double? horasComputables,
    String? modalidad,
    String? actividades,
    DateTime? createdAt,
  }) {
    return RegistroHora(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      descuentoAlmuerzoMinutos: descuentoAlmuerzoMinutos ?? this.descuentoAlmuerzoMinutos,
      horasComputables: horasComputables ?? this.horasComputables,
      modalidad: modalidad ?? this.modalidad,
      actividades: actividades ?? this.actividades,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

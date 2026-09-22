class HorarioDia {
  final String diaSemana; // 'lunes', 'martes', etc.
  final bool activo;
  final String horaInicio;
  final String horaFin;
  final int refrigerioMinutos;
  final String modalidad;

  const HorarioDia({
    required this.diaSemana,
    required this.activo,
    required this.horaInicio,
    required this.horaFin,
    required this.refrigerioMinutos,
    required this.modalidad,
  });

  HorarioDia copyWith({
    String? diaSemana,
    bool? activo,
    String? horaInicio,
    String? horaFin,
    int? refrigerioMinutos,
    String? modalidad,
  }) {
    return HorarioDia(
      diaSemana: diaSemana ?? this.diaSemana,
      activo: activo ?? this.activo,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      refrigerioMinutos: refrigerioMinutos ?? this.refrigerioMinutos,
      modalidad: modalidad ?? this.modalidad,
    );
  }
}

class HorarioDiaApiModel {
  final String diaSemana;
  final bool activo;
  final String horaInicio;
  final String horaFin;
  final int refrigerioMinutos;
  final String modalidad;

  const HorarioDiaApiModel({
    required this.diaSemana,
    required this.activo,
    required this.horaInicio,
    required this.horaFin,
    required this.refrigerioMinutos,
    required this.modalidad,
  });

  factory HorarioDiaApiModel.fromJson(Map<String, dynamic> json, [String defaultDia = 'lunes']) {
    return HorarioDiaApiModel(
      diaSemana: json['diaSemana']?.toString() ?? json['dia_semana']?.toString() ?? defaultDia,
      activo: json['activo'] == true,
      horaInicio: (json['horaInicio'] ?? json['hora_inicio'] ?? '08:00').toString().substring(0, 5),
      horaFin: (json['horaFin'] ?? json['hora_fin'] ?? '13:00').toString().substring(0, 5),
      refrigerioMinutos: (json['refrigerioMinutos'] ?? json['refrigerio_minutos'] ?? json['descuentoAlmuerzoMinutos'] ?? json['descuento_almuerzo_min'] ?? 0) as int,
      modalidad: json['modalidad']?.toString() ?? 'Presencial',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'diaSemana': diaSemana,
      'activo': activo,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'refrigerioMinutos': refrigerioMinutos,
      'modalidad': modalidad,
    };
  }
}

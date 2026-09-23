class RegistroHoraApiModel {
  final String id;
  final String? userId;
  final String fecha;
  final String horaInicio;
  final String horaFin;
  final int descuentoAlmuerzoMinutos;
  final double horasComputables;
  final String modalidad;
  final String actividades;
  final String? supervisorNombre;
  final String? estado;
  final String? createdAt;
  final String? updatedAt;

  const RegistroHoraApiModel({
    required this.id,
    this.userId,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    this.descuentoAlmuerzoMinutos = 0,
    required this.horasComputables,
    required this.modalidad,
    required this.actividades,
    this.supervisorNombre,
    this.estado,
    this.createdAt,
    this.updatedAt,
  });

  factory RegistroHoraApiModel.fromJson(Map<String, dynamic> json) {
    final double horas = (json['horasComputables'] ?? json['horas_computables'] ?? 0.0).toDouble();
    final int desc = (json['descuentoAlmuerzoMinutos'] ?? json['descuento_almuerzo_min'] ?? json['refrigerioMinutos'] ?? 0) as int;

    return RegistroHoraApiModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString(),
      fecha: (json['fecha']?.toString() ?? '').split('T')[0],
      horaInicio: (json['horaInicio'] ?? json['hora_inicio'] ?? '08:00').toString().substring(0, 5),
      horaFin: (json['horaFin'] ?? json['hora_fin'] ?? '13:00').toString().substring(0, 5),
      descuentoAlmuerzoMinutos: desc,
      horasComputables: horas,
      modalidad: json['modalidad']?.toString() ?? 'Presencial',
      actividades: json['actividades']?.toString() ?? '',
      supervisorNombre: json['supervisorNombre']?.toString() ?? json['supervisor_nombre']?.toString(),
      estado: json['estado']?.toString() ?? 'Aprobado',
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
      updatedAt: json['updatedAt']?.toString() ?? json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (userId != null) 'userId': userId,
      'fecha': fecha,
      'horaInicio': horaInicio,
      'horaFin': horaFin,
      'descuentoAlmuerzoMinutos': descuentoAlmuerzoMinutos,
      'horasComputables': horasComputables,
      'modalidad': modalidad,
      'actividades': actividades,
      if (supervisorNombre != null) 'supervisorNombre': supervisorNombre,
      if (estado != null) 'estado': estado,
    };
  }
}

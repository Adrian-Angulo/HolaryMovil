import 'horario_dia_api_model.dart';

class PerfilApiModel {
  final String? id;
  final String? email;
  final String nombre;
  final double metaHorasTotal;
  final double horasInicialesPrevias;
  final double horasMinimasSemanales;
  final String carrera;
  final String semestre;
  final bool perfilCompletado;
  final String? fechaInicio;
  final String? fechaFin;
  final Map<String, HorarioDiaApiModel> horarioSemanal;

  const PerfilApiModel({
    this.id,
    this.email,
    required this.nombre,
    required this.metaHorasTotal,
    this.horasInicialesPrevias = 0.0,
    this.horasMinimasSemanales = 30.0,
    this.carrera = 'Ingeniería de Sistemas',
    this.semestre = '2025-I',
    this.perfilCompletado = false,
    this.fechaInicio,
    this.fechaFin,
    required this.horarioSemanal,
  });

  factory PerfilApiModel.fromJson(Map<String, dynamic> json) {
    // Soportar respuesta anidada en data o directa
    final data = json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : json;

    final horarioRaw = data['horarioSemanal'] ?? data['horario_semanal'];
    final horarioMap = <String, HorarioDiaApiModel>{};

    if (horarioRaw is Map<String, dynamic>) {
      horarioRaw.forEach((k, v) {
        if (v is Map<String, dynamic>) {
          horarioMap[k] = HorarioDiaApiModel.fromJson(v, k);
        }
      });
    }

    final double metaTotal = (data['metaHorasTotal'] ?? data['meta_horas_total'] ?? data['metaHoras'] ?? data['meta_horas'] ?? 360.0).toDouble();
    final double horasPrevias = (data['horasInicialesPrevias'] ?? data['horas_iniciales_previas'] ?? 0.0).toDouble();
    final double horasMinimas = (data['horasMinimasSemanales'] ?? data['horas_minimas_semanales'] ?? 30.0).toDouble();

    return PerfilApiModel(
      id: data['id']?.toString(),
      email: data['email']?.toString(),
      nombre: data['nombre']?.toString() ?? data['nombreCompleto']?.toString() ?? data['nombre_completo']?.toString() ?? 'Practicante',
      metaHorasTotal: metaTotal,
      horasInicialesPrevias: horasPrevias,
      horasMinimasSemanales: horasMinimas,
      carrera: data['carrera']?.toString() ?? 'Ingeniería de Sistemas',
      semestre: data['semestre']?.toString() ?? '2025-I',
      perfilCompletado: data['perfilCompletado'] == true || data['perfil_completado'] == true,
      fechaInicio: data['fechaInicio']?.toString() ?? data['fecha_inicio']?.toString(),
      fechaFin: data['fechaFin']?.toString() ?? data['fecha_fin']?.toString(),
      horarioSemanal: horarioMap,
    );
  }

  Map<String, dynamic> toJson() {
    final horarioJson = <String, dynamic>{};
    horarioSemanal.forEach((k, v) {
      horarioJson[k] = v.toJson();
    });

    return {
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      'nombre': nombre,
      'nombreCompleto': nombre,
      'metaHorasTotal': metaHorasTotal,
      'metaHoras': metaHorasTotal.round(),
      'horasInicialesPrevias': horasInicialesPrevias,
      'horasMinimasSemanales': horasMinimasSemanales,
      'carrera': carrera,
      'semestre': semestre,
      'perfilCompletado': perfilCompletado,
      if (fechaInicio != null) 'fechaInicio': fechaInicio,
      if (fechaFin != null) 'fechaFin': fechaFin,
      'horarioSemanal': horarioJson,
    };
  }
}

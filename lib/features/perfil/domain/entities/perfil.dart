import 'horario_dia.dart';

class Perfil {
  final String nombre;
  final double metaHorasTotal;
  final double horasInicialesPrevias;
  final double horasMinimasSemanales;
  final String carrera;
  final String semestre;
  final bool perfilCompletado;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final Map<String, HorarioDia> horarioSemanal;

  const Perfil({
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

  double get minimoHorasSemana => horasMinimasSemanales;

  Perfil copyWith({
    String? nombre,
    double? metaHorasTotal,
    double? horasInicialesPrevias,
    double? horasMinimasSemanales,
    String? carrera,
    String? semestre,
    bool? perfilCompletado,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    Map<String, HorarioDia>? horarioSemanal,
  }) {
    return Perfil(
      nombre: nombre ?? this.nombre,
      metaHorasTotal: metaHorasTotal ?? this.metaHorasTotal,
      horasInicialesPrevias: horasInicialesPrevias ?? this.horasInicialesPrevias,
      horasMinimasSemanales: horasMinimasSemanales ?? this.horasMinimasSemanales,
      carrera: carrera ?? this.carrera,
      semestre: semestre ?? this.semestre,
      perfilCompletado: perfilCompletado ?? this.perfilCompletado,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      horarioSemanal: horarioSemanal ?? this.horarioSemanal,
    );
  }

  static Perfil defaultPerfil() {
    final now = DateTime.now();
    return Perfil(
      nombre: 'Practicante',
      metaHorasTotal: 360.0,
      horasInicialesPrevias: 0.0,
      horasMinimasSemanales: 30.0,
      carrera: 'Ingeniería de Sistemas',
      semestre: '2025-I',
      perfilCompletado: false,
      fechaInicio: DateTime(now.year, now.month, 1),
      fechaFin: DateTime(now.year, now.month + 3, 0),
      horarioSemanal: {
        'lunes': const HorarioDia(
          diaSemana: 'lunes',
          activo: true,
          horaInicio: '08:00',
          horaFin: '13:00',
          refrigerioMinutos: 0,
          modalidad: 'Presencial',
        ),
        'martes': const HorarioDia(
          diaSemana: 'martes',
          activo: true,
          horaInicio: '14:00',
          horaFin: '19:00',
          refrigerioMinutos: 0,
          modalidad: 'Presencial',
        ),
        'miercoles': const HorarioDia(
          diaSemana: 'miercoles',
          activo: true,
          horaInicio: '14:00',
          horaFin: '19:00',
          refrigerioMinutos: 0,
          modalidad: 'Presencial',
        ),
        'jueves': const HorarioDia(
          diaSemana: 'jueves',
          activo: true,
          horaInicio: '08:00',
          horaFin: '13:00',
          refrigerioMinutos: 0,
          modalidad: 'Presencial',
        ),
        'viernes': const HorarioDia(
          diaSemana: 'viernes',
          activo: true,
          horaInicio: '08:00',
          horaFin: '13:00',
          refrigerioMinutos: 0,
          modalidad: 'Presencial',
        ),
        'sabado': const HorarioDia(
          diaSemana: 'sabado',
          activo: false,
          horaInicio: '08:00',
          horaFin: '13:00',
          refrigerioMinutos: 0,
          modalidad: 'Presencial',
        ),
        'domingo': const HorarioDia(
          diaSemana: 'domingo',
          activo: false,
          horaInicio: '08:00',
          horaFin: '13:00',
          refrigerioMinutos: 0,
          modalidad: 'Presencial',
        ),
      },
    );
  }
}

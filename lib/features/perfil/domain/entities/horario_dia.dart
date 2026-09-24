import '../../../../core/utils/time_calculator.dart';

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

  bool get habilitado => activo;
  String get horaEntrada => horaInicio;
  String get horaSalida => horaFin;
  int get minutosColacion => refrigerioMinutos;
  double get horasEfectivas => TimeCalculator.calcularHorasNetas(horaInicio, horaFin);

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

  factory HorarioDia.porDefecto(String diaSemana) {
    final esFinDeSemana = diaSemana == 'sabado' || diaSemana == 'domingo';
    return HorarioDia(
      diaSemana: diaSemana,
      activo: !esFinDeSemana,
      horaInicio: '08:00',
      horaFin: '13:00',
      refrigerioMinutos: 0,
      modalidad: 'Presencial',
    );
  }
}

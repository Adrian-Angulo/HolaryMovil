import 'package:hive/hive.dart';

part 'registro_hora_hive_model.g.dart';

@HiveType(typeId: 0)
class RegistroHoraHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime fecha;

  @HiveField(2)
  final String horaInicio;

  @HiveField(3)
  final String horaFin;

  @HiveField(4)
  final int descuentoAlmuerzoMinutos;

  @HiveField(5)
  final double horasComputables;

  @HiveField(6)
  final String modalidad;

  @HiveField(7)
  final String actividades;

  @HiveField(8)
  final DateTime? createdAt;

  RegistroHoraHiveModel({
    required this.id,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.descuentoAlmuerzoMinutos,
    required this.horasComputables,
    required this.modalidad,
    required this.actividades,
    this.createdAt,
  });
}

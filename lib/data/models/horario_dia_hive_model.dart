import 'package:hive/hive.dart';

part 'horario_dia_hive_model.g.dart';

@HiveType(typeId: 1)
class HorarioDiaHiveModel extends HiveObject {
  @HiveField(0)
  final String diaSemana;

  @HiveField(1)
  final bool activo;

  @HiveField(2)
  final String horaInicio;

  @HiveField(3)
  final String horaFin;

  @HiveField(4)
  final int refrigerioMinutos;

  @HiveField(5)
  final String modalidad;

  HorarioDiaHiveModel({
    required this.diaSemana,
    required this.activo,
    required this.horaInicio,
    required this.horaFin,
    required this.refrigerioMinutos,
    required this.modalidad,
  });
}

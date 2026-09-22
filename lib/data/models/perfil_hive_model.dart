import 'package:hive/hive.dart';
import 'horario_dia_hive_model.dart';

part 'perfil_hive_model.g.dart';

@HiveType(typeId: 2)
class PerfilHiveModel extends HiveObject {
  @HiveField(0, defaultValue: 'Practicante')
  String nombre;

  @HiveField(1, defaultValue: 360.0)
  double metaHorasTotal;

  @HiveField(2)
  DateTime? fechaInicio;

  @HiveField(3)
  DateTime? fechaFin;

  @HiveField(4)
  Map<String, HorarioDiaHiveModel> horarioSemanal;

  @HiveField(5, defaultValue: 0.0)
  double horasInicialesPrevias;

  PerfilHiveModel({
    required this.nombre,
    required this.metaHorasTotal,
    this.fechaInicio,
    this.fechaFin,
    required this.horarioSemanal,
    this.horasInicialesPrevias = 0.0,
  });
}

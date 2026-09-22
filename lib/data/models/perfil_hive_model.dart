import 'package:hive/hive.dart';
import 'horario_dia_hive_model.dart';

part 'perfil_hive_model.g.dart';

@HiveType(typeId: 2)
class PerfilHiveModel extends HiveObject {
  @HiveField(0)
  String nombre;

  @HiveField(1)
  double metaHorasTotal;

  @HiveField(2)
  DateTime? fechaInicio;

  @HiveField(3)
  DateTime? fechaFin;

  @HiveField(4)
  Map<String, HorarioDiaHiveModel> horarioSemanal;

  PerfilHiveModel({
    required this.nombre,
    required this.metaHorasTotal,
    this.fechaInicio,
    this.fechaFin,
    required this.horarioSemanal,
  });
}

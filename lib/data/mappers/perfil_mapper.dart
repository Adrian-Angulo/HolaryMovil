import '../../domain/entities/horario_dia.dart';
import '../../domain/entities/perfil.dart';
import '../models/horario_dia_hive_model.dart';
import '../models/perfil_hive_model.dart';

class PerfilMapper {
  static HorarioDia horarioDiaToDomain(HorarioDiaHiveModel model) {
    return HorarioDia(
      diaSemana: model.diaSemana,
      activo: model.activo,
      horaInicio: model.horaInicio,
      horaFin: model.horaFin,
      refrigerioMinutos: model.refrigerioMinutos,
      modalidad: model.modalidad,
    );
  }

  static HorarioDiaHiveModel horarioDiaToHive(HorarioDia entity) {
    return HorarioDiaHiveModel(
      diaSemana: entity.diaSemana,
      activo: entity.activo,
      horaInicio: entity.horaInicio,
      horaFin: entity.horaFin,
      refrigerioMinutos: entity.refrigerioMinutos,
      modalidad: entity.modalidad,
    );
  }

  static Perfil toDomain(PerfilHiveModel model) {
    final Map<String, HorarioDia> horarioMap = {};
    model.horarioSemanal.forEach((key, val) {
      horarioMap[key] = horarioDiaToDomain(val);
    });

    return Perfil(
      nombre: model.nombre,
      metaHorasTotal: model.metaHorasTotal,
      horasInicialesPrevias: model.horasInicialesPrevias,
      fechaInicio: model.fechaInicio,
      fechaFin: model.fechaFin,
      horarioSemanal: horarioMap,
    );
  }

  static PerfilHiveModel toHive(Perfil entity) {
    final Map<String, HorarioDiaHiveModel> horarioMap = {};
    entity.horarioSemanal.forEach((key, val) {
      horarioMap[key] = horarioDiaToHive(val);
    });

    return PerfilHiveModel(
      nombre: entity.nombre,
      metaHorasTotal: entity.metaHorasTotal,
      horasInicialesPrevias: entity.horasInicialesPrevias,
      fechaInicio: entity.fechaInicio,
      fechaFin: entity.fechaFin,
      horarioSemanal: horarioMap,
    );
  }
}

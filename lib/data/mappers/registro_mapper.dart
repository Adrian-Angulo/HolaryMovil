import '../../domain/entities/registro_hora.dart';
import '../models/registro_hora_hive_model.dart';

class RegistroMapper {
  static RegistroHora toDomain(RegistroHoraHiveModel model) {
    return RegistroHora(
      id: model.id,
      fecha: model.fecha,
      horaInicio: model.horaInicio,
      horaFin: model.horaFin,
      descuentoAlmuerzoMinutos: model.descuentoAlmuerzoMinutos,
      horasComputables: model.horasComputables,
      modalidad: model.modalidad,
      actividades: model.actividades,
      createdAt: model.createdAt ?? model.fecha,
    );
  }

  static RegistroHoraHiveModel toHive(RegistroHora entity) {
    return RegistroHoraHiveModel(
      id: entity.id,
      fecha: entity.fecha,
      horaInicio: entity.horaInicio,
      horaFin: entity.horaFin,
      descuentoAlmuerzoMinutos: entity.descuentoAlmuerzoMinutos,
      horasComputables: entity.horasComputables,
      modalidad: entity.modalidad,
      actividades: entity.actividades,
      createdAt: entity.createdAt,
    );
  }
}

import '../../domain/entities/registro_hora.dart';
import '../models/registro_hora_api_model.dart';

class RegistroMapper {
  static RegistroHora toDomain(RegistroHoraApiModel model) {
    DateTime fechaParsed;
    try {
      fechaParsed = DateTime.parse(model.fecha);
    } catch (_) {
      fechaParsed = DateTime.now();
    }

    DateTime? createdParsed;
    if (model.createdAt != null && model.createdAt!.isNotEmpty) {
      try {
        createdParsed = DateTime.parse(model.createdAt!);
      } catch (_) {}
    }

    return RegistroHora(
      id: model.id,
      fecha: fechaParsed,
      horaInicio: model.horaInicio,
      horaFin: model.horaFin,
      descuentoAlmuerzoMinutos: model.descuentoAlmuerzoMinutos,
      horasComputables: model.horasComputables,
      modalidad: model.modalidad,
      actividades: model.actividades,
      createdAt: createdParsed ?? fechaParsed,
    );
  }

  static RegistroHoraApiModel toApi(RegistroHora entity) {
    final fechaStr = '${entity.fecha.year.toString().padLeft(4, '0')}-${entity.fecha.month.toString().padLeft(2, '0')}-${entity.fecha.day.toString().padLeft(2, '0')}';

    return RegistroHoraApiModel(
      id: entity.id,
      fecha: fechaStr,
      horaInicio: entity.horaInicio,
      horaFin: entity.horaFin,
      descuentoAlmuerzoMinutos: entity.descuentoAlmuerzoMinutos,
      horasComputables: entity.horasComputables,
      modalidad: entity.modalidad,
      actividades: entity.actividades,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}

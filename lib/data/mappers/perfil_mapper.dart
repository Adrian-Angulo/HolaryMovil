import '../../domain/entities/horario_dia.dart';
import '../../domain/entities/perfil.dart';
import '../models/horario_dia_api_model.dart';
import '../models/perfil_api_model.dart';

class PerfilMapper {
  static HorarioDia horarioDiaToDomain(HorarioDiaApiModel model) {
    return HorarioDia(
      diaSemana: model.diaSemana,
      activo: model.activo,
      horaInicio: model.horaInicio,
      horaFin: model.horaFin,
      refrigerioMinutos: model.refrigerioMinutos,
      modalidad: model.modalidad,
    );
  }

  static HorarioDiaApiModel horarioDiaToApi(HorarioDia entity) {
    return HorarioDiaApiModel(
      diaSemana: entity.diaSemana,
      activo: entity.activo,
      horaInicio: entity.horaInicio,
      horaFin: entity.horaFin,
      refrigerioMinutos: entity.refrigerioMinutos,
      modalidad: entity.modalidad,
    );
  }

  static Perfil toDomain(PerfilApiModel model) {
    final Map<String, HorarioDia> horarioMap = {};
    model.horarioSemanal.forEach((key, val) {
      horarioMap[key] = horarioDiaToDomain(val);
    });

    DateTime? fInicio;
    if (model.fechaInicio != null && model.fechaInicio!.isNotEmpty) {
      try {
        fInicio = DateTime.parse(model.fechaInicio!);
      } catch (_) {}
    }

    DateTime? fFin;
    if (model.fechaFin != null && model.fechaFin!.isNotEmpty) {
      try {
        fFin = DateTime.parse(model.fechaFin!);
      } catch (_) {}
    }

    return Perfil(
      nombre: model.nombre,
      metaHorasTotal: model.metaHorasTotal,
      horasInicialesPrevias: model.horasInicialesPrevias,
      horasMinimasSemanales: model.horasMinimasSemanales,
      carrera: model.carrera,
      semestre: model.semestre,
      perfilCompletado: model.perfilCompletado,
      fechaInicio: fInicio,
      fechaFin: fFin,
      horarioSemanal: horarioMap.isNotEmpty ? horarioMap : Perfil.defaultPerfil().horarioSemanal,
    );
  }

  static PerfilApiModel toApi(Perfil entity) {
    final Map<String, HorarioDiaApiModel> horarioMap = {};
    entity.horarioSemanal.forEach((key, val) {
      horarioMap[key] = horarioDiaToApi(val);
    });

    return PerfilApiModel(
      nombre: entity.nombre,
      metaHorasTotal: entity.metaHorasTotal,
      horasInicialesPrevias: entity.horasInicialesPrevias,
      horasMinimasSemanales: entity.horasMinimasSemanales,
      carrera: entity.carrera,
      semestre: entity.semestre,
      perfilCompletado: entity.perfilCompletado,
      fechaInicio: entity.fechaInicio != null ? entity.fechaInicio!.toIso8601String().split('T')[0] : null,
      fechaFin: entity.fechaFin != null ? entity.fechaFin!.toIso8601String().split('T')[0] : null,
      horarioSemanal: horarioMap,
    );
  }
}

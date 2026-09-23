import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/horario_dia.dart';
import '../../domain/entities/perfil.dart';
import 'dependency_injection.dart';

class PerfilNotifier extends StateNotifier<AsyncValue<Perfil>> {
  final Ref _ref;

  PerfilNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadPerfil();
  }

  Future<void> loadPerfil() async {
    state = const AsyncValue.loading();
    final getPerfil = _ref.read(getPerfilUseCaseProvider);
    final result = await getPerfil.execute();

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (perfil) async {
        state = AsyncValue.data(perfil);
        await _ref
            .read(sessionStorageProvider)
            .setPerfilCompletado(perfil.perfilCompletado);
      },
    );
  }

  Future<void> updatePerfil(Perfil perfil) async {
    final updatePerfil = _ref.read(updatePerfilUseCaseProvider);
    final result = await updatePerfil.execute(perfil);

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (_) async {
        state = AsyncValue.data(perfil);
        await _ref
            .read(sessionStorageProvider)
            .setPerfilCompletado(perfil.perfilCompletado);
      },
    );
  }

  Future<void> updateConfiguracionGeneral({
    required String nombre,
    required double metaHoras,
    required double horasInicialesPrevias,
    double? horasMinimasSemanales,
    bool? perfilCompletado,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    final current = state.value ?? Perfil.defaultPerfil();

    final updated = current.copyWith(
      nombre: nombre,
      metaHorasTotal: metaHoras,
      horasInicialesPrevias: horasInicialesPrevias,
      horasMinimasSemanales:
          horasMinimasSemanales ?? current.horasMinimasSemanales,
      perfilCompletado: perfilCompletado ?? current.perfilCompletado,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
    );
    await updatePerfil(updated);
  }

  Future<void> guardarPerfilInicial({
    required String nombre,
    required double metaHoras,
    required double horasInicialesPrevias,
    required double horasMinimasSemanales,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    Map<String, HorarioDia>? horarioSemanal,
  }) async {
    final current = state.value ?? Perfil.defaultPerfil();
    final updated = current.copyWith(
      nombre: nombre,
      metaHorasTotal: metaHoras,
      horasInicialesPrevias: horasInicialesPrevias,
      horasMinimasSemanales: horasMinimasSemanales,
      perfilCompletado: true,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      horarioSemanal: horarioSemanal ?? current.horarioSemanal,
    );
    await updatePerfil(updated);
  }

  Future<void> updateHorarioDia(String diaKey, HorarioDia horarioDia) async {
    final current = state.value;
    if (current == null) return;

    final updatedMap = Map<String, HorarioDia>.from(current.horarioSemanal);
    updatedMap[diaKey] = horarioDia;

    final updatedPerfil = current.copyWith(horarioSemanal: updatedMap);
    await updatePerfil(updatedPerfil);
  }
}

final perfilNotifierProvider =
    StateNotifierProvider<PerfilNotifier, AsyncValue<Perfil>>((ref) {
  return PerfilNotifier(ref);
});

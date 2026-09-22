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
    try {
      state = const AsyncValue.loading();
      final getPerfil = _ref.read(getPerfilUseCaseProvider);
      final perfil = await getPerfil.execute();
      state = AsyncValue.data(perfil);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updatePerfil(Perfil perfil) async {
    try {
      final updatePerfil = _ref.read(updatePerfilUseCaseProvider);
      await updatePerfil.execute(perfil);
      state = AsyncValue.data(perfil);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateConfiguracionGeneral({
    required String nombre,
    required double metaHoras,
    required double horasInicialesPrevias,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(
      nombre: nombre,
      metaHorasTotal: metaHoras,
      horasInicialesPrevias: horasInicialesPrevias,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
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

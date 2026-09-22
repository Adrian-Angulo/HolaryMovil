import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/registro_hora.dart';
import 'dependency_injection.dart';

class RegistrosNotifier extends StateNotifier<AsyncValue<List<RegistroHora>>> {
  final Ref _ref;

  RegistrosNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadRegistros();
  }

  Future<void> loadRegistros() async {
    try {
      state = const AsyncValue.loading();
      final getRegistros = _ref.read(getRegistrosUseCaseProvider);
      final registros = await getRegistros.execute();
      state = AsyncValue.data(registros);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addRegistro(RegistroHora registro) async {
    try {
      final addUseCase = _ref.read(addRegistroUseCaseProvider);
      await addUseCase.execute(registro);
      
      final currentList = state.value ?? [];
      final updatedList = [registro, ...currentList]
        ..sort((a, b) => b.fecha.compareTo(a.fecha));
      state = AsyncValue.data(updatedList);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateRegistro(RegistroHora registro) async {
    try {
      final updateUseCase = _ref.read(updateRegistroUseCaseProvider);
      await updateUseCase.execute(registro);

      final currentList = state.value ?? [];
      final updatedList = currentList.map((r) => r.id == registro.id ? registro : r).toList()
        ..sort((a, b) => b.fecha.compareTo(a.fecha));
      state = AsyncValue.data(updatedList);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteRegistro(String id) async {
    try {
      final deleteUseCase = _ref.read(deleteRegistroUseCaseProvider);
      await deleteUseCase.execute(id);

      final currentList = state.value ?? [];
      final updatedList = currentList.where((r) => r.id != id).toList();
      state = AsyncValue.data(updatedList);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final registrosNotifierProvider =
    StateNotifierProvider<RegistrosNotifier, AsyncValue<List<RegistroHora>>>((ref) {
  return RegistrosNotifier(ref);
});

// Filtro de búsqueda/mes para el historial
final historialFiltroMesProvider = StateProvider<DateTime?>((ref) => null);
final historialFiltroModalidadProvider = StateProvider<String?>((ref) => null);

// Provider derivado para la lista filtrada de historial
final historialFiltradoProvider = Provider<List<RegistroHora>>((ref) {
  final registrosAsync = ref.watch(registrosNotifierProvider);
  final mesFiltro = ref.watch(historialFiltroMesProvider);
  final modalidadFiltro = ref.watch(historialFiltroModalidadProvider);

  return registrosAsync.maybeWhen(
    data: (registros) {
      return registros.where((r) {
        // Filtro por mes/año
        if (mesFiltro != null) {
          if (r.fecha.year != mesFiltro.year || r.fecha.month != mesFiltro.month) {
            return false;
          }
        }
        // Filtro por modalidad
        if (modalidadFiltro != null && modalidadFiltro.isNotEmpty) {
          if (r.modalidad != modalidadFiltro) {
            return false;
          }
        }
        return true;
      }).toList();
    },
    orElse: () => [],
  );
});

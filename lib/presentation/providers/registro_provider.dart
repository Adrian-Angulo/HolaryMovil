import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/registro_hora.dart';
import 'dependency_injection.dart';

class RegistrosNotifier extends StateNotifier<AsyncValue<List<RegistroHora>>> {
  final Ref _ref;

  RegistrosNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadRegistros();
  }

  Future<void> loadRegistros() async {
    state = const AsyncValue.loading();
    final getRegistros = _ref.read(getRegistrosUseCaseProvider);
    final result = await getRegistros.execute();

    result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
      },
      (registros) {
        state = AsyncValue.data(registros);
      },
    );
  }

  Future<bool> addRegistro(RegistroHora registro) async {
    final addUseCase = _ref.read(addRegistroUseCaseProvider);
    final result = await addUseCase.execute(registro);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        final currentList = state.value ?? [];
        final updatedList = [registro, ...currentList]
          ..sort((a, b) => b.fecha.compareTo(a.fecha));
        state = AsyncValue.data(updatedList);
        return true;
      },
    );
  }

  Future<bool> updateRegistro(RegistroHora registro) async {
    final updateUseCase = _ref.read(updateRegistroUseCaseProvider);
    final result = await updateUseCase.execute(registro);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        final currentList = state.value ?? [];
        final updatedList = currentList
            .map((r) => r.id == registro.id ? registro : r)
            .toList()
          ..sort((a, b) => b.fecha.compareTo(a.fecha));
        state = AsyncValue.data(updatedList);
        return true;
      },
    );
  }

  Future<bool> deleteRegistro(String id) async {
    final deleteUseCase = _ref.read(deleteRegistroUseCaseProvider);
    final result = await deleteUseCase.execute(id);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        final currentList = state.value ?? [];
        final updatedList = currentList.where((r) => r.id != id).toList();
        state = AsyncValue.data(updatedList);
        return true;
      },
    );
  }
}

final registrosNotifierProvider = StateNotifierProvider<RegistrosNotifier,
    AsyncValue<List<RegistroHora>>>((ref) {
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
          if (r.fecha.year != mesFiltro.year ||
              r.fecha.month != mesFiltro.month) {
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

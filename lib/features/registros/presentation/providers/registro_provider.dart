import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:practi_horas_app/core/di/dependency_injection.dart';
import 'package:practi_horas_app/core/errors/failures.dart';
import 'package:practi_horas_app/features/registros/domain/entities/registro_hora.dart';
import 'package:practi_horas_app/features/registros/domain/usecases/add_registro_usecase.dart';
import 'package:practi_horas_app/features/registros/domain/usecases/delete_registro_usecase.dart';
import 'package:practi_horas_app/features/registros/domain/usecases/get_registros_usecase.dart';
import 'package:practi_horas_app/features/registros/domain/usecases/update_registro_usecase.dart';

final registrosNotifierProvider =
    StateNotifierProvider<RegistrosNotifier, AsyncValue<List<RegistroHora>>>(
  (ref) => RegistrosNotifier(
    getRegistrosUseCase: ref.watch(getRegistrosUseCaseProvider),
    addRegistroUseCase: ref.watch(addRegistroUseCaseProvider),
    updateRegistroUseCase: ref.watch(updateRegistroUseCaseProvider),
    deleteRegistroUseCase: ref.watch(deleteRegistroUseCaseProvider),
  ),
);

class RegistrosNotifier extends StateNotifier<AsyncValue<List<RegistroHora>>> {
  final GetRegistrosUseCase getRegistrosUseCase;
  final AddRegistroUseCase addRegistroUseCase;
  final UpdateRegistroUseCase updateRegistroUseCase;
  final DeleteRegistroUseCase deleteRegistroUseCase;

  RegistrosNotifier({
    required this.getRegistrosUseCase,
    required this.addRegistroUseCase,
    required this.updateRegistroUseCase,
    required this.deleteRegistroUseCase,
  }) : super(const AsyncValue.loading()) {
    cargarRegistros();
  }

  Future<void> cargarRegistros() async {
    state = const AsyncValue.loading();
    final result = await getRegistrosUseCase.execute();
    result.fold(
      (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
      (registros) => state = AsyncValue.data(registros),
    );
  }

  Future<void> loadRegistros() => cargarRegistros();

  Future<Failure?> agregarRegistro(RegistroHora registro) async {
    final result = await addRegistroUseCase.execute(registro);
    return result.fold(
      (failure) => failure,
      (_) {
        state.whenData((actuales) {
          state = AsyncValue.data([registro, ...actuales]);
        });
        return null;
      },
    );
  }

  Future<Failure?> actualizarRegistro(RegistroHora registro) async {
    final result = await updateRegistroUseCase.execute(registro);
    return result.fold(
      (failure) => failure,
      (_) {
        state.whenData((actuales) {
          state = AsyncValue.data(
            actuales.map((r) => r.id == registro.id ? registro : r).toList(),
          );
        });
        return null;
      },
    );
  }

  Future<Failure?> eliminarRegistro(String id) async {
    final result = await deleteRegistroUseCase.execute(id);
    return result.fold(
      (failure) => failure,
      (_) {
        state.whenData((actuales) {
          state = AsyncValue.data(actuales.where((r) => r.id != id).toList());
        });
        return null;
      },
    );
  }
}

// Filtro por modalidad en Historial
final historialFiltroModalidadProvider = StateProvider<String?>((ref) => null);

// Lista filtrada de registros para el Historial
final historialFiltradoProvider = Provider<List<RegistroHora>>((ref) {
  final registrosAsync = ref.watch(registrosNotifierProvider);
  final filtroModalidad = ref.watch(historialFiltroModalidadProvider);

  return registrosAsync.maybeWhen(
    data: (registros) {
      if (filtroModalidad == null) return registros;
      return registros.where((r) => r.modalidad == filtroModalidad).toList();
    },
    orElse: () => <RegistroHora>[],
  );
});

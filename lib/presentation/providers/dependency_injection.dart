import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/local_storage_datasource.dart';
import '../../data/repositories/perfil_repository_impl.dart';
import '../../data/repositories/registro_repository_impl.dart';
import '../../domain/repositories/i_perfil_repository.dart';
import '../../domain/repositories/i_registro_repository.dart';
import '../../domain/usecases/estadisticas/calculate_metricas_usecase.dart';
import '../../domain/usecases/perfil/get_perfil_usecase.dart';
import '../../domain/usecases/perfil/update_perfil_usecase.dart';
import '../../domain/usecases/registro/add_registro_usecase.dart';
import '../../domain/usecases/registro/delete_registro_usecase.dart';
import '../../domain/usecases/registro/get_registros_usecase.dart';
import '../../domain/usecases/registro/update_registro_usecase.dart';

// Data Source Provider
final localStorageDataSourceProvider = Provider<LocalStorageDataSource>((ref) {
  return LocalStorageDataSource();
});

// Repositories Providers (Abstracción -> Implementación)
final registroRepositoryProvider = Provider<IRegistroRepository>((ref) {
  final ds = ref.watch(localStorageDataSourceProvider);
  return RegistroRepositoryImpl(ds);
});

final perfilRepositoryProvider = Provider<IPerfilRepository>((ref) {
  final ds = ref.watch(localStorageDataSourceProvider);
  return PerfilRepositoryImpl(ds);
});

// Use Cases Providers
final getRegistrosUseCaseProvider = Provider<GetRegistrosUseCase>((ref) {
  return GetRegistrosUseCase(ref.watch(registroRepositoryProvider));
});

final addRegistroUseCaseProvider = Provider<AddRegistroUseCase>((ref) {
  return AddRegistroUseCase(ref.watch(registroRepositoryProvider));
});

final updateRegistroUseCaseProvider = Provider<UpdateRegistroUseCase>((ref) {
  return UpdateRegistroUseCase(ref.watch(registroRepositoryProvider));
});

final deleteRegistroUseCaseProvider = Provider<DeleteRegistroUseCase>((ref) {
  return DeleteRegistroUseCase(ref.watch(registroRepositoryProvider));
});

final getPerfilUseCaseProvider = Provider<GetPerfilUseCase>((ref) {
  return GetPerfilUseCase(ref.watch(perfilRepositoryProvider));
});

final updatePerfilUseCaseProvider = Provider<UpdatePerfilUseCase>((ref) {
  return UpdatePerfilUseCase(ref.watch(perfilRepositoryProvider));
});

final calculateMetricasUseCaseProvider = Provider<CalculateMetricasUseCase>((ref) {
  return CalculateMetricasUseCase();
});

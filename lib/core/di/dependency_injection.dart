import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';
import '../storage/session_storage.dart';

// Auth Feature
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/domain/usecases/request_password_reset_usecase.dart';
import '../../features/auth/domain/usecases/reset_password_usecase.dart';

// Dashboard Feature
import '../../features/dashboard/data/datasources/metricas_remote_datasource.dart';
import '../../features/dashboard/data/repositories/metricas_repository_impl.dart';
import '../../features/dashboard/domain/repositories/i_metricas_repository.dart';
import '../../features/dashboard/domain/usecases/calculate_metricas_usecase.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_metrics_usecase.dart';

// Perfil Feature
import '../../features/perfil/data/datasources/perfil_remote_datasource.dart';
import '../../features/perfil/data/repositories/perfil_repository_impl.dart';
import '../../features/perfil/domain/repositories/i_perfil_repository.dart';
import '../../features/perfil/domain/usecases/get_perfil_usecase.dart';
import '../../features/perfil/domain/usecases/update_perfil_usecase.dart';

// Registros Feature
import '../../features/registros/data/datasources/registro_remote_datasource.dart';
import '../../features/registros/data/repositories/registro_repository_impl.dart';
import '../../features/registros/domain/repositories/i_registro_repository.dart';
import '../../features/registros/domain/usecases/add_registro_usecase.dart';
import '../../features/registros/domain/usecases/delete_registro_usecase.dart';
import '../../features/registros/domain/usecases/get_registros_usecase.dart';
import '../../features/registros/domain/usecases/update_registro_usecase.dart';
import '../../features/registros/domain/usecases/validar_solapamiento_usecase.dart';

// -------------------------------------------------------------
// Core Storage & Network Providers
// -------------------------------------------------------------
final sessionStorageProvider = Provider<SessionStorage>((ref) {
  throw UnimplementedError('SessionStorage debe inicializarse antes de runApp');
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(sessionStorageProvider);
  return ApiClient(sessionStorage: storage);
});

// -------------------------------------------------------------
// Remote Data Sources (ISP & DIP)
// -------------------------------------------------------------
final authRemoteDataSourceProvider = Provider<IAuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final perfilRemoteDataSourceProvider = Provider<IPerfilRemoteDataSource>((ref) {
  return PerfilRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final registroRemoteDataSourceProvider = Provider<IRegistroRemoteDataSource>((ref) {
  return RegistroRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

final metricasRemoteDataSourceProvider = Provider<IMetricasRemoteDataSource>((ref) {
  return MetricasRemoteDataSourceImpl(ref.watch(apiClientProvider));
});

// -------------------------------------------------------------
// Repositories (DIP)
// -------------------------------------------------------------
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(sessionStorageProvider),
  );
});

final perfilRepositoryProvider = Provider<IPerfilRepository>((ref) {
  return PerfilRepositoryImpl(
    ref.watch(perfilRemoteDataSourceProvider),
    ref.watch(sessionStorageProvider),
  );
});

final registroRepositoryProvider = Provider<IRegistroRepository>((ref) {
  return RegistroRepositoryImpl(
    ref.watch(registroRemoteDataSourceProvider),
    ref.watch(sessionStorageProvider),
  );
});

final metricasRepositoryProvider = Provider<IMetricasRepository>((ref) {
  return MetricasRepositoryImpl(ref.watch(metricasRemoteDataSourceProvider));
});

// -------------------------------------------------------------
// Use Cases (SRP)
// -------------------------------------------------------------
// Auth Use Cases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final requestPasswordResetUseCaseProvider = Provider<RequestPasswordResetUseCase>((ref) {
  return RequestPasswordResetUseCase(ref.watch(authRepositoryProvider));
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

// Perfil Use Cases
final getPerfilUseCaseProvider = Provider<GetPerfilUseCase>((ref) {
  return GetPerfilUseCase(ref.watch(perfilRepositoryProvider));
});

final updatePerfilUseCaseProvider = Provider<UpdatePerfilUseCase>((ref) {
  return UpdatePerfilUseCase(ref.watch(perfilRepositoryProvider));
});

// Registros Use Cases
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

final validarSolapamientoUseCaseProvider = Provider<ValidarSolapamientoUseCase>((ref) {
  return ValidarSolapamientoUseCase();
});

// Dashboard Use Cases
final getDashboardMetricsUseCaseProvider = Provider<GetDashboardMetricsUseCase>((ref) {
  return GetDashboardMetricsUseCase(ref.watch(metricasRepositoryProvider));
});

final calculateMetricasUseCaseProvider = Provider<CalculateMetricasUseCase>((ref) {
  return CalculateMetricasUseCase();
});

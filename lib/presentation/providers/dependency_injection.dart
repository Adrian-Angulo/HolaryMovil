import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/session_storage.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/metricas_remote_datasource.dart';
import '../../data/datasources/perfil_remote_datasource.dart';
import '../../data/datasources/registro_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/metricas_repository_impl.dart';
import '../../data/repositories/perfil_repository_impl.dart';
import '../../data/repositories/registro_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/repositories/i_metricas_repository.dart';
import '../../domain/repositories/i_perfil_repository.dart';
import '../../domain/repositories/i_registro_repository.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/request_password_reset_usecase.dart';
import '../../domain/usecases/auth/reset_password_usecase.dart';
import '../../domain/usecases/estadisticas/calculate_metricas_usecase.dart';
import '../../domain/usecases/estadisticas/get_dashboard_metrics_usecase.dart';
import '../../domain/usecases/perfil/get_perfil_usecase.dart';
import '../../domain/usecases/perfil/update_perfil_usecase.dart';
import '../../domain/usecases/registro/add_registro_usecase.dart';
import '../../domain/usecases/registro/delete_registro_usecase.dart';
import '../../domain/usecases/registro/get_registros_usecase.dart';
import '../../domain/usecases/registro/update_registro_usecase.dart';

// Storage Provider (Sobrescrito en main.dart tras SharedPreferences.getInstance())
final sessionStorageProvider = Provider<SessionStorage>((ref) {
  throw UnimplementedError('SessionStorage debe inicializarse antes de runApp');
});

// HTTP Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(sessionStorageProvider);
  return ApiClient(sessionStorage: storage);
});

// Remote DataSources Providers
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

// Repositories Providers (DIP)
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(sessionStorageProvider),
  );
});

final perfilRepositoryProvider = Provider<IPerfilRepository>((ref) {
  return PerfilRepositoryImpl(ref.watch(perfilRemoteDataSourceProvider));
});

final registroRepositoryProvider = Provider<IRegistroRepository>((ref) {
  return RegistroRepositoryImpl(ref.watch(registroRemoteDataSourceProvider));
});

final metricasRepositoryProvider = Provider<IMetricasRepository>((ref) {
  return MetricasRepositoryImpl(ref.watch(metricasRemoteDataSourceProvider));
});

// Use Cases Providers
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

final getPerfilUseCaseProvider = Provider<GetPerfilUseCase>((ref) {
  return GetPerfilUseCase(ref.watch(perfilRepositoryProvider));
});

final updatePerfilUseCaseProvider = Provider<UpdatePerfilUseCase>((ref) {
  return UpdatePerfilUseCase(ref.watch(perfilRepositoryProvider));
});

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

final getDashboardMetricsUseCaseProvider = Provider<GetDashboardMetricsUseCase>((ref) {
  return GetDashboardMetricsUseCase(ref.watch(metricasRepositoryProvider));
});

final calculateMetricasUseCaseProvider = Provider<CalculateMetricasUseCase>((ref) {
  return CalculateMetricasUseCase();
});

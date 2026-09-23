import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../../core/storage/session_storage.dart';
import '../../domain/entities/perfil.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../mappers/perfil_mapper.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final IAuthRemoteDataSource _remoteDataSource;
  final SessionStorage _sessionStorage;

  AuthRepositoryImpl(this._remoteDataSource, this._sessionStorage);

  @override
  bool hasActiveSession() {
    return _sessionStorage.hasSession();
  }

  @override
  Future<Either<Failure, bool>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response =
          await _remoteDataSource.login(email: email, password: password);
      await _sessionStorage.saveToken(response.token);
      if (response.refreshToken != null) {
        await _sessionStorage.saveRefreshToken(response.refreshToken!);
      }
      await _sessionStorage.saveUserId(response.user.id);
      await _sessionStorage.saveUserEmail(response.user.email);
      await _sessionStorage.saveUserName(response.user.nombre);
      await _sessionStorage.setPerfilCompletado(response.user.perfilCompletado);
      return const Right(true);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, bool>> register({
    required String email,
    required String password,
    required String nombre,
    double? metaHoras,
    double? horasPrevias,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        email: email,
        password: password,
        nombre: nombre,
        metaHoras: metaHoras,
        horasPrevias: horasPrevias,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
      );

      await _sessionStorage.saveToken(response.token);
      if (response.refreshToken != null) {
        await _sessionStorage.saveRefreshToken(response.refreshToken!);
      }
      await _sessionStorage.saveUserId(response.user.id);
      await _sessionStorage.saveUserEmail(response.user.email);
      await _sessionStorage.saveUserName(response.user.nombre);
      await _sessionStorage.setPerfilCompletado(response.user.perfilCompletado);
      return const Right(true);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Perfil>> getCurrentUser() async {
    try {
      final apiModel = await _remoteDataSource.getMe();
      return Right(PerfilMapper.toDomain(apiModel));
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Ignorar errores del backend al cerrar sesión
    }
    await _sessionStorage.clearSession();
    return const Right(null);
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> requestPasswordReset(
      String email) async {
    try {
      final result = await _remoteDataSource.forgotPassword(email);
      return Right(result);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      return const Right(null);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }
}

import 'dart:convert';
import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/perfil.dart';
import '../../domain/repositories/i_perfil_repository.dart';
import '../datasources/perfil_remote_datasource.dart';
import '../mappers/perfil_mapper.dart';
import '../models/perfil_api_model.dart';

class PerfilRepositoryImpl implements IPerfilRepository {
  final IPerfilRemoteDataSource _remoteDataSource;
  final SessionStorage _sessionStorage;

  PerfilRepositoryImpl(this._remoteDataSource, this._sessionStorage);

  @override
  Future<Either<Failure, Perfil>> getPerfil() async {
    try {
      final apiModel = await _remoteDataSource.getProfile();
      await _sessionStorage.saveCachedPerfilJson(jsonEncode(apiModel.toJson()));
      await _sessionStorage.saveUserName(apiModel.nombre);
      await _sessionStorage.setPerfilCompletado(apiModel.perfilCompletado);
      return Right(PerfilMapper.toDomain(apiModel));
    } on UnauthorizedException catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      // Intento de fallback desde la caché local
      final cachedJson = _sessionStorage.getCachedPerfilJson();
      if (cachedJson != null && cachedJson.isNotEmpty) {
        try {
          final map = jsonDecode(cachedJson) as Map<String, dynamic>;
          final cachedModel = PerfilApiModel.fromJson(map);
          return Right(PerfilMapper.toDomain(cachedModel));
        } catch (_) {}
      }

      // Si no hay caché completa pero hay nombre en sesión, devolver perfil con nombre
      final userName = _sessionStorage.getUserName();
      if (userName != null && userName.isNotEmpty) {
        final fallback = Perfil.defaultPerfil().copyWith(
          nombre: userName,
          perfilCompletado: _sessionStorage.isPerfilCompletado(),
        );
        return Right(fallback);
      }

      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> savePerfil(Perfil perfil) async {
    try {
      final apiModel = PerfilMapper.toApi(perfil);
      await _remoteDataSource.updateProfile(apiModel);
      await _sessionStorage.saveCachedPerfilJson(jsonEncode(apiModel.toJson()));
      await _sessionStorage.saveUserName(perfil.nombre);
      await _sessionStorage.setPerfilCompletado(perfil.perfilCompletado);
      return const Right(null);
    } catch (e) {
      // Si estamos sin conexión, guardar en local de todos modos
      try {
        final apiModel = PerfilMapper.toApi(perfil);
        await _sessionStorage.saveCachedPerfilJson(jsonEncode(apiModel.toJson()));
        await _sessionStorage.saveUserName(perfil.nombre);
        await _sessionStorage.setPerfilCompletado(perfil.perfilCompletado);
      } catch (_) {}
      return Left(Failure.fromException(e));
    }
  }
}

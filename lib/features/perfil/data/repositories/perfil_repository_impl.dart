import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/perfil.dart';
import '../../domain/repositories/i_perfil_repository.dart';
import '../datasources/perfil_remote_datasource.dart';
import '../mappers/perfil_mapper.dart';

/// Implementación 100% conectada al servidor del repositorio de perfil.
/// No utiliza caché de respaldo offline; las operaciones requieren conectividad.
class PerfilRepositoryImpl implements IPerfilRepository {
  final IPerfilRemoteDataSource _remoteDataSource;
  final SessionStorage _sessionStorage;

  PerfilRepositoryImpl(this._remoteDataSource, this._sessionStorage);

  @override
  Future<Either<Failure, Perfil>> getPerfil() async {
    try {
      final apiModel = await _remoteDataSource.getProfile();
      await _sessionStorage.saveUserName(apiModel.nombre);
      await _sessionStorage.setPerfilCompletado(apiModel.perfilCompletado);
      return Right(PerfilMapper.toDomain(apiModel));
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> savePerfil(Perfil perfil) async {
    try {
      final apiModel = PerfilMapper.toApi(perfil);
      await _remoteDataSource.updateProfile(apiModel);
      await _sessionStorage.saveUserName(perfil.nombre);
      await _sessionStorage.setPerfilCompletado(perfil.perfilCompletado);
      return const Right(null);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }
}

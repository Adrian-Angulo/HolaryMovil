import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/perfil.dart';
import '../../domain/repositories/i_perfil_repository.dart';
import '../datasources/perfil_remote_datasource.dart';
import '../mappers/perfil_mapper.dart';

class PerfilRepositoryImpl implements IPerfilRepository {
  final IPerfilRemoteDataSource _remoteDataSource;

  PerfilRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, Perfil>> getPerfil() async {
    try {
      final apiModel = await _remoteDataSource.getProfile();
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
      return const Right(null);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }
}

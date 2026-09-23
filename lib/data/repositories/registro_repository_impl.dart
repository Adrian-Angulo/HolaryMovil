import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/registro_hora.dart';
import '../../domain/repositories/i_registro_repository.dart';
import '../datasources/registro_remote_datasource.dart';
import '../mappers/registro_mapper.dart';

class RegistroRepositoryImpl implements IRegistroRepository {
  final IRegistroRemoteDataSource _remoteDataSource;

  RegistroRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<RegistroHora>>> getRegistros() async {
    try {
      final apiModels = await _remoteDataSource.getRegistros();
      return Right(apiModels.map(RegistroMapper.toDomain).toList());
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, RegistroHora?>> getRegistroById(String id) async {
    final result = await getRegistros();
    return result.fold(
      (failure) => Left(failure),
      (all) {
        try {
          final found = all.firstWhere((r) => r.id == id);
          return Right(found);
        } catch (_) {
          return const Right(null);
        }
      },
    );
  }

  @override
  Future<Either<Failure, void>> saveRegistro(RegistroHora registro) async {
    try {
      final apiModel = RegistroMapper.toApi(registro);
      await _remoteDataSource.createRegistro(apiModel);
      return const Right(null);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateRegistro(RegistroHora registro) async {
    try {
      final apiModel = RegistroMapper.toApi(registro);
      await _remoteDataSource.updateRegistro(apiModel);
      return const Right(null);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRegistro(String id) async {
    try {
      await _remoteDataSource.deleteRegistro(id);
      return const Right(null);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<RegistroHora>>> getRegistrosByRangoFecha(
    DateTime inicio,
    DateTime fin,
  ) async {
    try {
      final desde =
          '${inicio.year.toString().padLeft(4, '0')}-${inicio.month.toString().padLeft(2, '0')}-${inicio.day.toString().padLeft(2, '0')}';
      final hasta =
          '${fin.year.toString().padLeft(4, '0')}-${fin.month.toString().padLeft(2, '0')}-${fin.day.toString().padLeft(2, '0')}';

      final apiModels =
          await _remoteDataSource.getRegistros(desde: desde, hasta: hasta);
      return Right(apiModels.map(RegistroMapper.toDomain).toList());
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }
}

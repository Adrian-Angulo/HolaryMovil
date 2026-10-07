import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/registro_hora.dart';
import '../../domain/repositories/i_registro_repository.dart';
import '../datasources/registro_remote_datasource.dart';
import '../mappers/registro_mapper.dart';

/// Implementación directa y 100% conectada al servidor del repositorio de registros.
/// No almacena caché local ni maneja colas de sincronización offline.
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
    try {
      final apiModels = await _remoteDataSource.getRegistros();
      try {
        final found = apiModels.firstWhere((r) => r.id == id);
        return Right(RegistroMapper.toDomain(found));
      } catch (_) {
        return const Right(null);
      }
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> saveRegistro(RegistroHora registro) async {
    final apiModel = RegistroMapper.toApi(registro);
    try {
      await _remoteDataSource.createRegistro(apiModel);
      return const Right(null);
    } catch (e) {
      return Left(Failure.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> updateRegistro(RegistroHora registro) async {
    final apiModel = RegistroMapper.toApi(registro);
    try {
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

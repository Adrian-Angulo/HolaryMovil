import 'dart:convert';
import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_exceptions.dart';
import '../../../../core/storage/session_storage.dart';
import '../../domain/entities/registro_hora.dart';
import '../../domain/repositories/i_registro_repository.dart';
import '../datasources/registro_remote_datasource.dart';
import '../mappers/registro_mapper.dart';
import '../models/registro_hora_api_model.dart';

class RegistroRepositoryImpl implements IRegistroRepository {
  final IRegistroRemoteDataSource _remoteDataSource;
  final SessionStorage _sessionStorage;

  RegistroRepositoryImpl(this._remoteDataSource, this._sessionStorage);

  List<RegistroHoraApiModel> _getLocalCachedModels() {
    final cachedJson = _sessionStorage.getCachedRegistrosJson();
    if (cachedJson != null && cachedJson.isNotEmpty) {
      try {
        final listDynamic = jsonDecode(cachedJson) as List<dynamic>;
        return listDynamic
            .map((item) =>
                RegistroHoraApiModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {}
    }
    return [];
  }

  Future<void> _saveLocalCachedModels(List<RegistroHoraApiModel> models) async {
    final jsonStr = jsonEncode(models.map((m) => m.toJson()).toList());
    await _sessionStorage.saveCachedRegistrosJson(jsonStr);
  }

  Future<void> _addToSyncQueue(Map<String, dynamic> action) async {
    try {
      final queueJson = _sessionStorage.getSyncQueueJson();
      List<dynamic> queue = [];
      if (queueJson != null && queueJson.isNotEmpty) {
        queue = jsonDecode(queueJson) as List<dynamic>;
      }
      queue.add(action);
      await _sessionStorage.saveSyncQueueJson(jsonEncode(queue));
    } catch (_) {}
  }

  @override
  Future<void> sincronizarPendientes() async {
    final queueJson = _sessionStorage.getSyncQueueJson();
    if (queueJson == null || queueJson.isEmpty) return;

    try {
      final queue = (jsonDecode(queueJson) as List<dynamic>)
          .map((item) => item as Map<String, dynamic>)
          .toList();

      final List<Map<String, dynamic>> remaining = [];

      for (final item in queue) {
        try {
          final action = item['action'] as String;
          if (action == 'create') {
            final data = item['data'] as Map<String, dynamic>;
            await _remoteDataSource.createRegistro(RegistroHoraApiModel.fromJson(data));
          } else if (action == 'update') {
            final data = item['data'] as Map<String, dynamic>;
            await _remoteDataSource.updateRegistro(RegistroHoraApiModel.fromJson(data));
          } else if (action == 'delete') {
            final id = item['id'] as String;
            await _remoteDataSource.deleteRegistro(id);
          }
        } catch (_) {
          remaining.add(item);
        }
      }

      if (remaining.isEmpty) {
        await _sessionStorage.saveSyncQueueJson('');
      } else {
        await _sessionStorage.saveSyncQueueJson(jsonEncode(remaining));
      }
    } catch (_) {}
  }

  @override
  Future<Either<Failure, List<RegistroHora>>> getRegistros() async {
    try {
      // Intentar sincronizar cola pendiente si hay conexión
      await sincronizarPendientes();

      final apiModels = await _remoteDataSource.getRegistros();
      await _saveLocalCachedModels(apiModels);
      return Right(apiModels.map(RegistroMapper.toDomain).toList());
    } on UnauthorizedException catch (e) {
      return Left(Failure.fromException(e));
    } catch (e) {
      final cachedModels = _getLocalCachedModels();
      if (cachedModels.isNotEmpty) {
        return Right(cachedModels.map(RegistroMapper.toDomain).toList());
      }
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
    final apiModel = RegistroMapper.toApi(registro);

    try {
      await _remoteDataSource.createRegistro(apiModel);
      // Actualizar caché
      final current = _getLocalCachedModels();
      current.removeWhere((r) => r.id == apiModel.id);
      current.insert(0, apiModel);
      await _saveLocalCachedModels(current);
      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(Failure.fromException(e));
    } catch (_) {
      // Modo Offline: Guardar en caché y encolar
      final current = _getLocalCachedModels();
      current.removeWhere((r) => r.id == apiModel.id);
      current.insert(0, apiModel);
      await _saveLocalCachedModels(current);

      await _addToSyncQueue({
        'action': 'create',
        'data': apiModel.toJson(),
      });
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> updateRegistro(RegistroHora registro) async {
    final apiModel = RegistroMapper.toApi(registro);

    try {
      await _remoteDataSource.updateRegistro(apiModel);
      final current = _getLocalCachedModels();
      final idx = current.indexWhere((r) => r.id == apiModel.id);
      if (idx != -1) {
        current[idx] = apiModel;
      } else {
        current.insert(0, apiModel);
      }
      await _saveLocalCachedModels(current);
      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(Failure.fromException(e));
    } catch (_) {
      // Modo Offline: Guardar en caché y encolar
      final current = _getLocalCachedModels();
      final idx = current.indexWhere((r) => r.id == apiModel.id);
      if (idx != -1) {
        current[idx] = apiModel;
      } else {
        current.insert(0, apiModel);
      }
      await _saveLocalCachedModels(current);

      await _addToSyncQueue({
        'action': 'update',
        'data': apiModel.toJson(),
      });
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> deleteRegistro(String id) async {
    try {
      await _remoteDataSource.deleteRegistro(id);
      final current = _getLocalCachedModels();
      current.removeWhere((r) => r.id == id);
      await _saveLocalCachedModels(current);
      return const Right(null);
    } on UnauthorizedException catch (e) {
      return Left(Failure.fromException(e));
    } catch (_) {
      // Modo Offline: Eliminar de caché y encolar
      final current = _getLocalCachedModels();
      current.removeWhere((r) => r.id == id);
      await _saveLocalCachedModels(current);

      await _addToSyncQueue({
        'action': 'delete',
        'id': id,
      });
      return const Right(null);
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
      final cached = _getLocalCachedModels();
      final filtered = cached.where((r) {
        try {
          final f = DateTime.parse(r.fecha);
          return f.isAfter(inicio.subtract(const Duration(days: 1))) &&
              f.isBefore(fin.add(const Duration(days: 1)));
        } catch (_) {
          return false;
        }
      }).map(RegistroMapper.toDomain).toList();

      return Right(filtered);
    }
  }
}

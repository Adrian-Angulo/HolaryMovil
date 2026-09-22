import '../../domain/entities/registro_hora.dart';
import '../../domain/repositories/i_registro_repository.dart';
import '../datasources/local_storage_datasource.dart';
import '../mappers/registro_mapper.dart';

class RegistroRepositoryImpl implements IRegistroRepository {
  final LocalStorageDataSource _dataSource;

  RegistroRepositoryImpl(this._dataSource);

  @override
  Future<List<RegistroHora>> getRegistros() async {
    final hiveModels = _dataSource.getAllRegistros();
    return hiveModels.map(RegistroMapper.toDomain).toList();
  }

  @override
  Future<RegistroHora?> getRegistroById(String id) async {
    final hiveModel = _dataSource.getRegistroById(id);
    if (hiveModel == null) return null;
    return RegistroMapper.toDomain(hiveModel);
  }

  @override
  Future<void> saveRegistro(RegistroHora registro) async {
    final hiveModel = RegistroMapper.toHive(registro);
    await _dataSource.saveRegistro(hiveModel);
  }

  @override
  Future<void> updateRegistro(RegistroHora registro) async {
    final hiveModel = RegistroMapper.toHive(registro);
    await _dataSource.saveRegistro(hiveModel);
  }

  @override
  Future<void> deleteRegistro(String id) async {
    await _dataSource.deleteRegistro(id);
  }

  @override
  Future<List<RegistroHora>> getRegistrosByRangoFecha(DateTime inicio, DateTime fin) async {
    final all = await getRegistros();
    return all.where((r) =>
      (r.fecha.isAfter(inicio) || r.fecha.isAtSameMomentAs(inicio)) &&
      (r.fecha.isBefore(fin) || r.fecha.isAtSameMomentAs(fin))
    ).toList();
  }
}

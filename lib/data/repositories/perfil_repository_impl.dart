import '../../domain/entities/perfil.dart';
import '../../domain/repositories/i_perfil_repository.dart';
import '../datasources/local_storage_datasource.dart';
import '../mappers/perfil_mapper.dart';

class PerfilRepositoryImpl implements IPerfilRepository {
  final LocalStorageDataSource _dataSource;

  PerfilRepositoryImpl(this._dataSource);

  @override
  Future<Perfil> getPerfil() async {
    final hiveModel = _dataSource.getPerfil();
    return PerfilMapper.toDomain(hiveModel);
  }

  @override
  Future<void> savePerfil(Perfil perfil) async {
    final hiveModel = PerfilMapper.toHive(perfil);
    await _dataSource.savePerfil(hiveModel);
  }
}

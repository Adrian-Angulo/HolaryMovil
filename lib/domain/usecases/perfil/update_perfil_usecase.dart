import '../../entities/perfil.dart';
import '../../repositories/i_perfil_repository.dart';

class UpdatePerfilUseCase {
  final IPerfilRepository _repository;

  UpdatePerfilUseCase(this._repository);

  Future<void> execute(Perfil perfil) {
    return _repository.savePerfil(perfil);
  }
}

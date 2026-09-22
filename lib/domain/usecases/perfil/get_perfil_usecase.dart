import '../../entities/perfil.dart';
import '../../repositories/i_perfil_repository.dart';

class GetPerfilUseCase {
  final IPerfilRepository _repository;

  GetPerfilUseCase(this._repository);

  Future<Perfil> execute() {
    return _repository.getPerfil();
  }
}

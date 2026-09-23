import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/perfil.dart';
import '../../repositories/i_perfil_repository.dart';

class GetPerfilUseCase {
  final IPerfilRepository _repository;

  GetPerfilUseCase(this._repository);

  Future<Either<Failure, Perfil>> execute() {
    return _repository.getPerfil();
  }
}

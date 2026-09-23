import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/perfil.dart';
import '../../repositories/i_auth_repository.dart';

class GetCurrentUserUseCase {
  final IAuthRepository _repository;

  GetCurrentUserUseCase(this._repository);

  Future<Either<Failure, Perfil>> execute() {
    return _repository.getCurrentUser();
  }
}

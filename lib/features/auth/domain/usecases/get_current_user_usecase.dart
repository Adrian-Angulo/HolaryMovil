import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../../../perfil/domain/entities/perfil.dart';
import '../repositories/i_auth_repository.dart';

class GetCurrentUserUseCase {
  final IAuthRepository _authRepository;

  GetCurrentUserUseCase(this._authRepository);

  Future<Either<Failure, Perfil>> call() {
    return _authRepository.getCurrentUser();
  }
}

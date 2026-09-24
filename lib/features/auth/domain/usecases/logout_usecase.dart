import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_auth_repository.dart';

class LogoutUseCase {
  final IAuthRepository _authRepository;

  LogoutUseCase(this._authRepository);

  Future<Either<Failure, void>> call() {
    return _authRepository.logout();
  }
}

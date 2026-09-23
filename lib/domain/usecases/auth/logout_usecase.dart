import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/i_auth_repository.dart';

class LogoutUseCase {
  final IAuthRepository _repository;

  LogoutUseCase(this._repository);

  Future<Either<Failure, void>> execute() {
    return _repository.logout();
  }
}

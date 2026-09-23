import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository _repository;

  LoginUseCase(this._repository);

  Future<Either<Failure, bool>> execute({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}

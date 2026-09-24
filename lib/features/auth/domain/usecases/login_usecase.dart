import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<Either<Failure, bool>> call({
    required String email,
    required String password,
  }) {
    return _authRepository.login(
      email: email,
      password: password,
    );
  }
}

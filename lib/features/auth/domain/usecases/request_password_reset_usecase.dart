import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_auth_repository.dart';

class RequestPasswordResetUseCase {
  final IAuthRepository _authRepository;

  RequestPasswordResetUseCase(this._authRepository);

  Future<Either<Failure, Map<String, dynamic>>> call(String email) {
    return _authRepository.requestPasswordReset(email);
  }
}

import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/i_auth_repository.dart';

class ResetPasswordUseCase {
  final IAuthRepository _authRepository;

  ResetPasswordUseCase(this._authRepository);

  Future<Either<Failure, void>> execute({
    required String token,
    required String newPassword,
  }) async {
    return await _authRepository.resetPassword(
      token: token,
      newPassword: newPassword,
    );
  }
}

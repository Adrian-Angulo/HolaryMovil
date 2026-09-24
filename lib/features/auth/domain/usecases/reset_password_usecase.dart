import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_auth_repository.dart';

class ResetPasswordUseCase {
  final IAuthRepository _authRepository;

  ResetPasswordUseCase(this._authRepository);

  Future<Either<Failure, void>> call({
    required String token,
    required String newPassword,
  }) {
    return _authRepository.resetPassword(
      token: token,
      newPassword: newPassword,
    );
  }
}

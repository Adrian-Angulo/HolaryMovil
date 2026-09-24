import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/i_auth_repository.dart';

class RegisterUseCase {
  final IAuthRepository _authRepository;

  RegisterUseCase(this._authRepository);

  Future<Either<Failure, bool>> call({
    required String email,
    required String password,
    required String nombre,
    double? metaHoras,
    double? horasPrevias,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) {
    return _authRepository.register(
      email: email,
      password: password,
      nombre: nombre,
      metaHoras: metaHoras,
      horasPrevias: horasPrevias,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
    );
  }
}

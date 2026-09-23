import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/i_auth_repository.dart';

class RegisterUseCase {
  final IAuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<Either<Failure, bool>> execute({
    required String email,
    required String password,
    required String nombre,
    double? metaHoras,
    double? horasPrevias,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) {
    return _repository.register(
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

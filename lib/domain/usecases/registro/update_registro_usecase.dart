import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/registro_hora.dart';
import '../../repositories/i_registro_repository.dart';

class UpdateRegistroUseCase {
  final IRegistroRepository _repository;

  UpdateRegistroUseCase(this._repository);

  Future<Either<Failure, void>> execute(RegistroHora registro) {
    return _repository.updateRegistro(registro);
  }
}

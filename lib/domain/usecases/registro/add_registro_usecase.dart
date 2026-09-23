import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../entities/registro_hora.dart';
import '../../repositories/i_registro_repository.dart';

class AddRegistroUseCase {
  final IRegistroRepository _repository;

  AddRegistroUseCase(this._repository);

  Future<Either<Failure, void>> execute(RegistroHora registro) {
    return _repository.saveRegistro(registro);
  }
}

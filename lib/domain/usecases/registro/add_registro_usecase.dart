import '../../entities/registro_hora.dart';
import '../../repositories/i_registro_repository.dart';

class AddRegistroUseCase {
  final IRegistroRepository _repository;

  AddRegistroUseCase(this._repository);

  Future<void> execute(RegistroHora registro) {
    return _repository.saveRegistro(registro);
  }
}

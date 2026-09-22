import '../../entities/registro_hora.dart';
import '../../repositories/i_registro_repository.dart';

class GetRegistrosUseCase {
  final IRegistroRepository _repository;

  GetRegistrosUseCase(this._repository);

  Future<List<RegistroHora>> execute() {
    return _repository.getRegistros();
  }
}

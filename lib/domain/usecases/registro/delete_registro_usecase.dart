import '../../repositories/i_registro_repository.dart';

class DeleteRegistroUseCase {
  final IRegistroRepository _repository;

  DeleteRegistroUseCase(this._repository);

  Future<void> execute(String id) {
    return _repository.deleteRegistro(id);
  }
}

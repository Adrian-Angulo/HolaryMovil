import '../../../core/errors/either.dart';
import '../../../core/errors/failures.dart';
import '../../repositories/i_registro_repository.dart';

class DeleteRegistroUseCase {
  final IRegistroRepository _repository;

  DeleteRegistroUseCase(this._repository);

  Future<Either<Failure, void>> execute(String id) {
    return _repository.deleteRegistro(id);
  }
}

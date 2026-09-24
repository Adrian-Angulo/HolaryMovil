import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/registro_hora.dart';
import '../repositories/i_registro_repository.dart';

class GetRegistrosUseCase {
  final IRegistroRepository _repository;

  GetRegistrosUseCase(this._repository);

  Future<Either<Failure, List<RegistroHora>>> call() {
    return _repository.getRegistros();
  }

  Future<Either<Failure, List<RegistroHora>>> execute() => call();
}

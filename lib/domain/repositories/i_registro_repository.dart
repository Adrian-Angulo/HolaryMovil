import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../entities/registro_hora.dart';

abstract class IRegistroRepository {
  Future<Either<Failure, List<RegistroHora>>> getRegistros();
  Future<Either<Failure, RegistroHora?>> getRegistroById(String id);
  Future<Either<Failure, void>> saveRegistro(RegistroHora registro);
  Future<Either<Failure, void>> updateRegistro(RegistroHora registro);
  Future<Either<Failure, void>> deleteRegistro(String id);
  Future<Either<Failure, List<RegistroHora>>> getRegistrosByRangoFecha(
    DateTime inicio,
    DateTime fin,
  );
}

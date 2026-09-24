import '../../../../core/errors/either.dart';
import '../../../../core/errors/failures.dart';
import '../entities/perfil.dart';

abstract class IPerfilRepository {
  Future<Either<Failure, Perfil>> getPerfil();
  Future<Either<Failure, void>> savePerfil(Perfil perfil);
}

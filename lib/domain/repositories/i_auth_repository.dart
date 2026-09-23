import '../../core/errors/either.dart';
import '../../core/errors/failures.dart';
import '../entities/perfil.dart';

abstract class IAuthRepository {
  Future<Either<Failure, bool>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, bool>> register({
    required String email,
    required String password,
    required String nombre,
    double? metaHoras,
    double? horasPrevias,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  });

  Future<Either<Failure, Perfil>> getCurrentUser();
  Future<Either<Failure, void>> logout();
  bool hasActiveSession();
  Future<Either<Failure, Map<String, dynamic>>> requestPasswordReset(String email);
  Future<Either<Failure, void>> resetPassword({
    required String token,
    required String newPassword,
  });
}

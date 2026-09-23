import 'dart:async';
import 'dart:io';
import '../network/api_exceptions.dart';

/// Jerarquía de Fallos de Dominio con mensajes claros y comprensibles para el usuario
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  String toString() => message;

  /// Conversor inteligente de cualquier excepción técnica a un Failure amigable en español
  factory Failure.fromException(dynamic error) {
    if (error is Failure) return error;

    if (error is NetworkException || error is SocketException || error is TimeoutException) {
      return const NetworkFailure(
        'No se pudo conectar con el servidor. Revisa tu conexión a internet o verifica la dirección IP del servidor.',
      );
    }

    if (error is UnauthorizedException) {
      final msg = error.message.isNotEmpty
          ? error.message
          : 'Tu sesión ha expirado o tus credenciales son incorrectas. Por favor inicia sesión nuevamente.';
      return AuthFailure(msg);
    }

    if (error is NotFoundException) {
      return NotFoundFailure(
        error.message.isNotEmpty ? error.message : 'El recurso solicitado no fue encontrado.',
      );
    }

    if (error is BadRequestException) {
      final msg = error.message.isNotEmpty ? error.message : 'Los datos ingresados no son válidos.';
      return ValidationFailure(msg);
    }

    if (error is ApiException) {
      if (error.statusCode >= 500) {
        return const ServerFailure(
          'El servidor tuvo un problema temporal. Por favor inténtalo de nuevo en unos momentos.',
        );
      }
      return ServerFailure(
        error.message.isNotEmpty ? error.message : 'Ocurrió un error al procesar la solicitud.',
      );
    }

    final str = error.toString().replaceFirst('Exception:', '').trim();
    if (str.toLowerCase().contains('connection refused') ||
        str.toLowerCase().contains('failed host lookup') ||
        str.toLowerCase().contains('socket')) {
      return const NetworkFailure(
        'No se pudo conectar con el backend. Asegúrate de que el servidor esté activo.',
      );
    }

    return UnknownFailure(
      str.isNotEmpty ? str : 'Ocurrió un error imprevisto. Por favor inténtalo nuevamente.',
    );
  }
}

/// Fallo cuando el servidor responde con 5xx o errores de infraestructura
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error en el servidor. Por favor intenta más tarde.', super.code = 'SERVER_ERROR']);
}

/// Fallo de conexión de red o timeout
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión con el servidor. Verifica tu internet.', super.code = 'NETWORK_ERROR']);
}

/// Fallo de credenciales o autenticación
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Credenciales inválidas o sesión no autorizada.', super.code = 'AUTH_ERROR']);
}

/// Fallo de validación de formulario o datos de entrada
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Los datos proporcionados son inválidos.', super.code = 'VALIDATION_ERROR']);
}

/// Fallo cuando el elemento buscado no existe
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'El elemento solicitado no fue encontrado.', super.code = 'NOT_FOUND']);
}

/// Fallo de conflicto de datos (ej. correo duplicado)
class ConflictFailure extends Failure {
  const ConflictFailure([super.message = 'Ya existe un registro con estos datos.', super.code = 'CONFLICT_ERROR']);
}

/// Fallo de almacenamiento local
class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Error al guardar datos en el dispositivo.', super.code = 'STORAGE_ERROR']);
}

/// Fallo genérico
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Ocurrió un error inesperado.', super.code = 'UNKNOWN_ERROR']);
}

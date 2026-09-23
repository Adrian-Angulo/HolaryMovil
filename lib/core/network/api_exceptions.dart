class ApiException implements Exception {
  final int statusCode;
  final String error;
  final String message;
  final dynamic details;

  ApiException({
    required this.statusCode,
    required this.error,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'ApiException [$statusCode - $error]: $message';
}

class NetworkException extends ApiException {
  NetworkException({super.message = 'Sin conexión con el servidor. Verifica tu conexión a internet.'})
      : super(statusCode: 0, error: 'NetworkError');
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({super.message = 'Sesión expirada o no autorizada. Por favor inicia sesión nuevamente.'})
      : super(statusCode: 401, error: 'Unauthorized');
}

class NotFoundException extends ApiException {
  NotFoundException({super.message = 'El recurso solicitado no fue encontrado.'})
      : super(statusCode: 404, error: 'NotFound');
}

class BadRequestException extends ApiException {
  BadRequestException({required super.message, super.details})
      : super(statusCode: 400, error: 'BadRequest');
}

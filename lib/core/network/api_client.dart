import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../storage/session_storage.dart';
import 'api_exceptions.dart';

class ApiClient {
  final http.Client _httpClient;
  final SessionStorage sessionStorage;

  ApiClient({
    http.Client? httpClient,
    required this.sessionStorage,
  }) : _httpClient = httpClient ?? http.Client();

  String get baseUrl => sessionStorage.getCustomBaseUrl();

  Map<String, String> _buildHeaders([Map<String, String>? extraHeaders]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    final token = sessionStorage.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final fullPath = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final pathNormalized = path.startsWith('/') ? path : '/$path';
    final urlString = '$fullPath$pathNormalized';

    if (queryParameters != null && queryParameters.isNotEmpty) {
      final cleanParams = <String, String>{};
      queryParameters.forEach((key, value) {
        if (value != null) {
          cleanParams[key] = value.toString();
        }
      });
      return Uri.parse(urlString).replace(queryParameters: cleanParams);
    }

    return Uri.parse(urlString);
  }

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await _httpClient
          .get(uri, headers: _buildHeaders(headers))
          .timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException(message: 'Tiempo de espera agotado al conectar con el servidor.');
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await _httpClient
          .post(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException(message: 'Tiempo de espera agotado al conectar con el servidor.');
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await _httpClient
          .put(
            uri,
            headers: _buildHeaders(headers),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException(message: 'Tiempo de espera agotado al conectar con el servidor.');
    }
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, queryParameters);
      final response = await _httpClient
          .delete(uri, headers: _buildHeaders(headers))
          .timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw NetworkException(message: 'Tiempo de espera agotado al conectar con el servidor.');
    }
  }

  dynamic _processResponse(http.Response response) {
    dynamic body;
    try {
      if (response.body.isNotEmpty) {
        body = jsonDecode(response.body);
      }
    } catch (_) {
      body = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    String message = 'Ocurrió un error en la solicitud.';
    String errorType = 'Error';
    dynamic details;

    if (body is Map) {
      if (body['message'] is String && (body['message'] as String).isNotEmpty) {
        message = body['message'] as String;
      } else if (body['error'] is Map && (body['error'] as Map)['message'] is String) {
        message = (body['error'] as Map)['message'] as String;
      }

      if (body['error'] is String) {
        errorType = body['error'] as String;
      } else if (body['error'] is Map && (body['error'] as Map)['code'] is String) {
        errorType = (body['error'] as Map)['code'] as String;
      }

      if (body['detalles'] != null) {
        details = body['detalles'];
      } else if (body['error'] is Map && (body['error'] as Map)['detalles'] != null) {
        details = (body['error'] as Map)['detalles'];
      }
    }

    if (response.statusCode == 401) {
      throw UnauthorizedException(message: message);
    } else if (response.statusCode == 404) {
      throw NotFoundException(message: message);
    } else if (response.statusCode == 400) {
      throw BadRequestException(message: message, details: details);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        error: errorType,
        message: message,
        details: details,
      );
    }
  }
}

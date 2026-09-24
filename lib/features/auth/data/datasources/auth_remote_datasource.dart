import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../perfil/data/models/perfil_api_model.dart';
import '../models/auth_response_model.dart';

abstract class IAuthRemoteDataSource {
  Future<AuthResponseModel> login({required String email, required String password});
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String nombre,
    double? metaHoras,
    double? horasPrevias,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  });
  Future<PerfilApiModel> getMe();
  Future<void> logout();
  Future<Map<String, dynamic>> forgotPassword(String email);
  Future<void> resetPassword({required String token, required String newPassword});
}

class AuthRemoteDataSourceImpl implements IAuthRemoteDataSource {
  final ApiClient _client;

  AuthRemoteDataSourceImpl(this._client);

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      AppConstants.authLoginEndpoint,
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );
    return AuthResponseModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<AuthResponseModel> register({
    required String email,
    required String password,
    required String nombre,
    double? metaHoras,
    double? horasPrevias,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    final body = <String, dynamic>{
      'email': email.trim().toLowerCase(),
      'password': password,
      'nombre': nombre.trim(),
      'nombreCompleto': nombre.trim(),
      if (metaHoras != null) 'metaHorasTotal': metaHoras,
      if (horasPrevias != null) 'horasInicialesPrevias': horasPrevias,
      if (fechaInicio != null) 'fechaInicio': fechaInicio.toIso8601String().split('T')[0],
      if (fechaFin != null) 'fechaFin': fechaFin.toIso8601String().split('T')[0],
    };

    final response = await _client.post(
      AppConstants.authRegisterEndpoint,
      body: body,
    );
    return AuthResponseModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<PerfilApiModel> getMe() async {
    final response = await _client.get(AppConstants.authMeEndpoint);
    return PerfilApiModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post('/auth/logout');
    } catch (_) {
      // Ignorar errores al cerrar sesión
    }
  }

  @override
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    final response = await _client.post(
      '/auth/forgot-password',
      body: {'email': email.trim().toLowerCase()},
    );
    return response as Map<String, dynamic>;
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _client.post(
      '/auth/reset-password',
      body: {
        'token': token.trim(),
        'newPassword': newPassword,
      },
    );
  }
}

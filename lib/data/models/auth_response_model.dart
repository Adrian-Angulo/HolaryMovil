class AuthUserModel {
  final String id;
  final String email;
  final String nombre;
  final bool perfilCompletado;

  const AuthUserModel({
    required this.id,
    required this.email,
    required this.nombre,
    this.perfilCompletado = false,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? json['nombreCompleto']?.toString() ?? '',
      perfilCompletado: json['perfilCompletado'] == true || json['perfil_completado'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'perfilCompletado': perfilCompletado,
    };
  }
}

class AuthResponseModel {
  final String token;
  final String? refreshToken;
  final AuthUserModel user;

  const AuthResponseModel({
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    // Soportar data anidada o respuesta directa
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;

    final token = data['token']?.toString() ?? data['accessToken']?.toString() ?? '';
    final refreshToken = data['refreshToken']?.toString();
    final userJson = data['user'] is Map<String, dynamic> ? data['user'] as Map<String, dynamic> : data;

    return AuthResponseModel(
      token: token,
      refreshToken: refreshToken,
      user: AuthUserModel.fromJson(userJson),
    );
  }
}

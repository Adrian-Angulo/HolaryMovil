/// Constantes centralizadas para todas las rutas de navegación de la aplicación.
/// Mantiene la consistencia y evita "magic strings" a lo largo del proyecto.
abstract final class AppRoutes {
  /// Pantalla inicial de carga y verificación de sesión.
  static const String splash = '/splash';

  /// Pantalla de autenticación (Login y Registro inicial con email/password).
  static const String auth = '/auth';

  /// Pantalla obligatoria de configuración inicial de perfil de prácticas.
  static const String registroPerfil = '/registro-perfil';

  /// Pantalla principal (Shell / Dashboard de la aplicación).
  static const String home = '/home';
}


class AppConstants {
  static const String appName = 'Horaly';

  // API Base URL (Producción en Render)
  static const String apiBaseUrl = 'https://practihoras-backend.onrender.com/api/v1';

  // Endpoints
  static const String authRegisterEndpoint = '/auth/register';
  static const String authLoginEndpoint = '/auth/login';
  static const String authMeEndpoint = '/auth/me';
  static const String profileEndpoint = '/profile';
  static const String registrosEndpoint = '/registros';
  static const String metricasDashboardEndpoint = '/metricas/dashboard';
  static const String syncBatchEndpoint = '/sync/batch';

  // SharedPreferences Keys
  static const String tokenKey = 'auth_access_token';
  static const String refreshTokenKey = 'auth_refresh_token';
  static const String userIdKey = 'auth_user_id';
  static const String userEmailKey = 'auth_user_email';
  static const String userNameKey = 'auth_user_name';
  static const String perfilCompletadoKey = 'auth_perfil_completado';
  static const String cachedPerfilKey = 'cache_perfil_data';
  static const String cachedRegistrosKey = 'cache_registros_data';
  static const String syncQueueKey = 'offline_sync_queue';

  // Días de la semana normalizados
  static const List<String> diasSemanaKeys = [
    'lunes',
    'martes',
    'miercoles',
    'jueves',
    'viernes',
    'sabado',
    'domingo',
  ];

  static const Map<String, String> diasSemanaNombres = {
    'lunes': 'Lunes',
    'martes': 'Martes',
    'miercoles': 'Miércoles',
    'jueves': 'Jueves',
    'viernes': 'Viernes',
    'sabado': 'Sábado',
    'domingo': 'Domingo',
  };

  // Modalidades de trabajo
  static const List<String> modalidades = ['Presencial', 'Remoto'];
}

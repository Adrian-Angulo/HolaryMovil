class AppConstants {
  static const String appName = 'PractiHoras';
  
  // Hive Box Names
  static const String registrosBoxName = 'practi_registros_box';
  static const String perfilBoxName = 'practi_perfil_box';
  static const String perfilKey = 'main_user_profile';

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
  static const List<String> modalidades = [
    'Presencial',
    'Remoto',
    'Híbrido',
  ];
}

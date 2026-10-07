import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/dependency_injection.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/perfil/presentation/providers/perfil_provider.dart';

/// Representa los estados posibles de autenticación y onboarding del usuario.
enum AuthStatus {
  /// Estado inicial durante el arranque o splash.
  initial,

  /// El usuario no cuenta con una sesión activa o token válido.
  unauthenticated,

  /// El usuario tiene sesión iniciada pero no ha completado la configuración inicial de perfil.
  needsProfileCompletion,

  /// El usuario tiene sesión válida y su perfil de horas está configurado.
  authenticated,
}

/// Provider reactivo que consolida la sesión de autenticación y el estado del perfil.
/// GoRouter utiliza este estado único para decidir redirecciones deterministas.
final authStatusProvider = Provider<AuthStatus>((ref) {
  // Observa cambios en el estado de autenticación (login, logout, errores)
  ref.watch(authNotifierProvider);

  // Consulta la persistencia local de sesión
  final storage = ref.watch(sessionStorageProvider);

  // Observa el estado del perfil en memoria/remoto
  final perfilAsync = ref.watch(perfilNotifierProvider);

  // 1. Si no hay sesión ni token, el usuario debe autenticarse
  if (!storage.hasSession()) {
    return AuthStatus.unauthenticated;
  }

  // 2. Verificar si el perfil fue completado tanto en storage como en el provider
  final bool isCompletado = storage.isPerfilCompletado() ||
      (perfilAsync.value?.perfilCompletado ?? false);

  if (!isCompletado) {
    return AuthStatus.needsProfileCompletion;
  }

  // 3. Usuario totalmente autenticado y configurado
  return AuthStatus.authenticated;
});


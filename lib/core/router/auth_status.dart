import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/dependency_injection.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/perfil/presentation/providers/perfil_provider.dart';

enum AuthStatus {
  initial,
  unauthenticated,
  needsProfileCompletion,
  authenticated,
}

final authStatusProvider = Provider<AuthStatus>((ref) {
  ref.watch(authNotifierProvider);
  final storage = ref.watch(sessionStorageProvider);
  final perfilAsync = ref.watch(perfilNotifierProvider);

  if (!storage.hasSession()) {
    return AuthStatus.unauthenticated;
  }

  final bool isCompletado = storage.isPerfilCompletado() ||
      (perfilAsync.value?.perfilCompletado ?? false);

  if (!isCompletado) {
    return AuthStatus.needsProfileCompletion;
  }

  return AuthStatus.authenticated;
});

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_status.dart';

/// Notificador que actúa de puente entre el estado reactivo de Riverpod
/// y el ciclo de vida de [GoRouter] mediante la interfaz [Listenable].
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    // Escucha cambios en [authStatusProvider] y notifica a GoRouter para re-evaluar redirecciones
    _ref.listen<AuthStatus>(
      authStatusProvider,
      (previous, next) {
        if (previous != next) {
          notifyListeners();
        }
      },
    );
  }
}

/// Provider que expone la instancia de [RouterNotifier] a GoRouter.
final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});


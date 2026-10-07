import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_routes.dart';

/// Provee acceso a la clave global de navegación y métodos utilitarios
/// para redirección fuera del árbol de widgets (e.g. interceptores HTTP / 401).
abstract final class AppNavigator {
  /// Clave global compartida con GoRouter.
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Cierra la sesión y redirige inmediatamente a la pantalla de autenticación.
  static void logoutAndRedirectToAuth() {
    final context = navigatorKey.currentContext;
    if (context != null && context.mounted) {
      context.go(AppRoutes.auth);
    }
  }
}


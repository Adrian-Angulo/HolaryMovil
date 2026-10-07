import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../utils/app_navigator.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/perfil/presentation/screens/registro_perfil_screen.dart';
import '../../features/shell/presentation/screens/home_navigation_screen.dart';
import '../../features/shell/presentation/screens/splash_screen.dart';
import 'app_routes.dart';
import 'auth_status.dart';
import 'router_notifier.dart';

CustomTransitionPage<void> _buildFadeTransitionPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: child,
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: AppNavigator.navigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: routerNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final status = ref.read(authStatusProvider);
      final String location = state.matchedLocation;

      if (location == AppRoutes.splash) {
        return null;
      }

      final bool isGoingToAuth = location == AppRoutes.auth;

      return switch (status) {
        AuthStatus.unauthenticated => isGoingToAuth ? null : AppRoutes.auth,
        AuthStatus.needsProfileCompletion =>
          location == AppRoutes.registroPerfil ? null : AppRoutes.registroPerfil,
        AuthStatus.authenticated =>
          (isGoingToAuth || location == AppRoutes.registroPerfil)
              ? AppRoutes.home
              : null,
        AuthStatus.initial => null,
      };
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => _buildFadeTransitionPage(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.auth,
        pageBuilder: (context, state) => _buildFadeTransitionPage(
          context: context,
          state: state,
          child: const AuthScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.registroPerfil,
        pageBuilder: (context, state) => _buildFadeTransitionPage(
          context: context,
          state: state,
          child: const RegistroPerfilScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        pageBuilder: (context, state) => _buildFadeTransitionPage(
          context: context,
          state: state,
          child: const HomeNavigationScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Ruta no encontrada',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No pudimos encontrar la pantalla solicitada:\n${state.uri}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.home_rounded, size: 18),
                  label: const Text('Volver al Inicio'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
});

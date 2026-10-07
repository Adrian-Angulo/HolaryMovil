import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:practi_horas_app/core/constants/app_constants.dart';
import 'package:practi_horas_app/core/di/dependency_injection.dart';
import 'package:practi_horas_app/core/router/app_routes.dart';
import 'package:practi_horas_app/core/router/auth_status.dart';
import 'package:practi_horas_app/core/storage/session_storage.dart';
import 'package:practi_horas_app/features/perfil/domain/entities/perfil.dart';
import 'package:practi_horas_app/features/perfil/presentation/providers/perfil_provider.dart';

class _MockPerfilNotifier extends PerfilNotifier {
  _MockPerfilNotifier(super.ref, Perfil? perfil) {
    if (perfil != null) {
      state = AsyncValue.data(perfil);
    } else {
      state = const AsyncValue.loading();
    }
  }

  @override
  Future<void> loadPerfil() async {
    // No-op en pruebas
  }
}

void main() {
  group('GoRouter & AuthStatus Tests (Fase 5 - Verificación)', () {
    test('Prueba 5.1: Sin sesión retorna AuthStatus.unauthenticated', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = SessionStorage(prefs);

      final container = ProviderContainer(
        overrides: [
          sessionStorageProvider.overrideWithValue(storage),
          perfilNotifierProvider.overrideWith((ref) => _MockPerfilNotifier(ref, null)),
        ],
      );

      final status = container.read(authStatusProvider);
      expect(status, AuthStatus.unauthenticated);
    });

    test('Prueba 5.2: Con sesión pero perfil incompleto retorna AuthStatus.needsProfileCompletion', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.tokenKey: 'valid_mock_jwt_token',
        AppConstants.perfilCompletadoKey: false,
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = SessionStorage(prefs);

      final container = ProviderContainer(
        overrides: [
          sessionStorageProvider.overrideWithValue(storage),
          perfilNotifierProvider.overrideWith((ref) => _MockPerfilNotifier(ref, null)),
        ],
      );

      final status = container.read(authStatusProvider);
      expect(status, AuthStatus.needsProfileCompletion);
    });

    test('Prueba 5.3: Con sesión y perfil completado en storage retorna AuthStatus.authenticated', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.tokenKey: 'valid_mock_jwt_token',
        AppConstants.perfilCompletadoKey: true,
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = SessionStorage(prefs);

      final container = ProviderContainer(
        overrides: [
          sessionStorageProvider.overrideWithValue(storage),
          perfilNotifierProvider.overrideWith((ref) => _MockPerfilNotifier(ref, null)),
        ],
      );

      final status = container.read(authStatusProvider);
      expect(status, AuthStatus.authenticated);
    });

    test('Prueba 5.4: Con sesión y perfil completado en Provider en memoria retorna AuthStatus.authenticated', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.tokenKey: 'valid_mock_jwt_token',
        AppConstants.perfilCompletadoKey: false,
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = SessionStorage(prefs);

      final perfilCompletado = Perfil.defaultPerfil().copyWith(perfilCompletado: true);

      final container = ProviderContainer(
        overrides: [
          sessionStorageProvider.overrideWithValue(storage),
          perfilNotifierProvider.overrideWith((ref) => _MockPerfilNotifier(ref, perfilCompletado)),
        ],
      );

      final status = container.read(authStatusProvider);
      expect(status, AuthStatus.authenticated);
    });

    test('Prueba 5.5: Limpieza de sesión (Logout o 401) revierte estado a unauthenticated', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.tokenKey: 'expired_token',
        AppConstants.perfilCompletadoKey: true,
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = SessionStorage(prefs);

      final container = ProviderContainer(
        overrides: [
          sessionStorageProvider.overrideWithValue(storage),
          perfilNotifierProvider.overrideWith((ref) => _MockPerfilNotifier(ref, null)),
        ],
      );

      expect(container.read(authStatusProvider), AuthStatus.authenticated);

      // Simular logout o token 401
      await storage.clearSession();
      container.invalidate(authStatusProvider);

      expect(container.read(authStatusProvider), AuthStatus.unauthenticated);
    });

    test('Prueba 5.6: Constantes de rutas AppRoutes están bien formateadas', () {
      expect(AppRoutes.splash, '/splash');
      expect(AppRoutes.auth, '/auth');
      expect(AppRoutes.registroPerfil, '/registro-perfil');
      expect(AppRoutes.home, '/home');
    });
  });
}

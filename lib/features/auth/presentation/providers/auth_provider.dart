import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:practi_horas_app/core/di/dependency_injection.dart';
import 'package:practi_horas_app/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:practi_horas_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:practi_horas_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:practi_horas_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:practi_horas_app/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:practi_horas_app/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:practi_horas_app/features/perfil/domain/entities/perfil.dart';

class AuthState {
  final Perfil? user;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    Perfil? user,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final RequestPasswordResetUseCase requestPasswordResetUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;

  AuthNotifier({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.requestPasswordResetUseCase,
    required this.resetPasswordUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
  }) : super(const AuthState()) {
    checkCurrentUser();
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> checkCurrentUser() async {
    final result = await getCurrentUserUseCase();
    result.fold(
      (_) => null,
      (user) {
        state = state.copyWith(user: user);
      },
    );
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await loginUseCase(email: email, password: password);
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          isLoading: false,
          clearError: true,
        );
        return success;
      },
    );
  }

  Future<bool> register({
    required String email,
    required String password,
    String? nombre,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final finalNombre = (nombre != null && nombre.trim().isNotEmpty)
        ? nombre.trim()
        : email.split('@').first;
    final result = await registerUseCase(
      email: email,
      password: password,
      nombre: finalNombre,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (success) {
        state = state.copyWith(
          isLoading: false,
          clearError: true,
        );
        return success;
      },
    );
  }

  Future<Map<String, dynamic>?> requestPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await requestPasswordResetUseCase(email);
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return null;
      },
      (data) {
        state = state.copyWith(
          isLoading: false,
          successMessage: data['message']?.toString() ?? 'Correo enviado',
          clearError: true,
        );
        return data;
      },
    );
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await resetPasswordUseCase(
      token: token,
      newPassword: newPassword,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'Contraseña restablecida exitosamente',
          clearError: true,
        );
        return true;
      },
    );
  }

  Future<void> logout() async {
    await logoutUseCase();
    state = const AuthState();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    requestPasswordResetUseCase: ref.watch(requestPasswordResetUseCaseProvider),
    resetPasswordUseCase: ref.watch(resetPasswordUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
  );
});

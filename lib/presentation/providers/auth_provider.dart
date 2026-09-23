import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/perfil.dart';
import 'dependency_injection.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? errorMessage;
  final Perfil? currentUser;

  const AuthState({
    required this.isAuthenticated,
    this.isLoading = false,
    this.errorMessage,
    this.currentUser,
  });

  factory AuthState.initial({required bool hasSession}) {
    return AuthState(
      isAuthenticated: hasSession,
      isLoading: false,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? errorMessage,
    Perfil? currentUser,
    bool clearError = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentUser: currentUser ?? this.currentUser,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthNotifier(this._ref)
      : super(AuthState.initial(
          hasSession: _ref.read(sessionStorageProvider).hasSession(),
        ));

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final loginUseCase = _ref.read(loginUseCaseProvider);
    final result = await loginUseCase.execute(email: email, password: password);

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
          isAuthenticated: true,
          isLoading: false,
          clearError: true,
        );
        return true;
      },
    );
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nombre,
    double? metaHoras,
    double? horasPrevias,
    DateTime? fechaInicio,
    DateTime? fechaFin,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final registerUseCase = _ref.read(registerUseCaseProvider);
    final result = await registerUseCase.execute(
      email: email,
      password: password,
      nombre: nombre,
      metaHoras: metaHoras,
      horasPrevias: horasPrevias,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
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
          isAuthenticated: true,
          isLoading: false,
          clearError: true,
        );
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<Map<String, dynamic>?> requestPasswordReset(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final useCase = _ref.read(requestPasswordResetUseCaseProvider);
    final result = await useCase.execute(email);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return null;
      },
      (data) {
        state = state.copyWith(isLoading: false, clearError: true);
        return data;
      },
    );
  }

  Future<bool> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final useCase = _ref.read(resetPasswordUseCaseProvider);
    final result =
        await useCase.execute(token: token, newPassword: newPassword);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false, clearError: true);
        return true;
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    final logoutUseCase = _ref.read(logoutUseCaseProvider);
    await logoutUseCase.execute();
    state = const AuthState(isAuthenticated: false, isLoading: false);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

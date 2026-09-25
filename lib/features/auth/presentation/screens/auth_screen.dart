import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:practi_horas_app/core/di/dependency_injection.dart';
import 'package:practi_horas_app/core/shared_atomic/atoms/app_logo.dart';
import 'package:practi_horas_app/features/perfil/presentation/providers/perfil_provider.dart';
import 'package:practi_horas_app/features/perfil/presentation/screens/registro_perfil_screen.dart';
import 'package:practi_horas_app/features/shell/presentation/screens/home_navigation_screen.dart';
import 'package:practi_horas_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:practi_horas_app/features/auth/presentation/widgets/organisms/forgot_password_modal.dart';
import 'package:practi_horas_app/features/auth/presentation/widgets/organisms/login_form_organism.dart';
import 'package:practi_horas_app/features/auth/presentation/widgets/organisms/register_form_organism.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String email, String password) async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final success = await authNotifier.login(email: email, password: password);

    if (success && mounted) {
      await _checkAndNavigate();
    }
  }

  Future<void> _handleRegister({
    required String email,
    required String password,
  }) async {
    final authNotifier = ref.read(authNotifierProvider.notifier);
    final success = await authNotifier.register(
      email: email,
      password: password,
    );

    if (success && mounted) {
      await _checkAndNavigate();
    }
  }

  Future<void> _checkAndNavigate() async {
    final storage = ref.read(sessionStorageProvider);
    final bool perfilCompletado = storage.isPerfilCompletado();

    ref.invalidate(perfilNotifierProvider);

    if (mounted) {
      final Widget destino = perfilCompletado
          ? const HomeNavigationScreen()
          : const RegistroPerfilScreen();

      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => destino));
    }
  }

  void _openForgotPasswordModal() {
    ForgotPasswordModal.show(
      context: context,
      onRequestReset: (email) =>
          ref.read(authNotifierProvider.notifier).requestPasswordReset(email),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    next.errorMessage!,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ref.read(authNotifierProvider.notifier).clearError();
              },
            ),
          ),
        );
      }
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        _showSuccessSnackBar(next.successMessage!);
      }
    });

    final Color bgGradientStart =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final Color bgGradientEnd =
        isDark ? const Color(0xFF020617) : const Color(0xFFEEF2FF);
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    const Color brandPrimary = Color(0xFF4F46E5);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgGradientStart, bgGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTopBar(isDark),
                    const SizedBox(height: 24),
                    _buildHeroHeader(isDark),
                    const SizedBox(height: 28),
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.3)
                                : const Color(0xFF4F46E5)
                                    .withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        children: [
                          _buildTabBar(isDark, brandPrimary),
                          const SizedBox(height: 22),
                          AnimatedCrossFade(
                            firstChild: LoginFormOrganism(
                              isLoading: authState.isLoading,
                              onLogin: _handleLogin,
                              onForgotPassword: _openForgotPasswordModal,
                              isDark: isDark,
                            ),
                            secondChild: RegisterFormOrganism(
                              isLoading: authState.isLoading,
                              onRegister: _handleRegister,
                              isDark: isDark,
                            ),
                            crossFadeState: _selectedTabIndex == 0
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                            duration: const Duration(milliseconds: 250),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildFooter(isDark),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return FadeInDown(
      duration: const Duration(milliseconds: 350),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFC7D2FE),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Portal Practicante',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFF93C5FD)
                      : const Color(0xFF4338CA),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(bool isDark) {
    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      child: Column(
        children: [
          const AppLogo(size: 58, borderRadius: 18),
          const SizedBox(height: 12),
          Text(
            'Horaly',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Control y Seguimiento de Horas de Práctica',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark, Color brandPrimary) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(0);
                setState(() => _selectedTabIndex = 0);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? (isDark ? const Color(0xFF334155) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedTabIndex == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.login_rounded,
                      size: 16,
                      color: _selectedTabIndex == 0
                          ? (isDark ? Colors.white : brandPrimary)
                          : (isDark ? Colors.white54 : const Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Iniciar Sesión',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: _selectedTabIndex == 0
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: _selectedTabIndex == 0
                            ? (isDark ? Colors.white : brandPrimary)
                            : (isDark
                                ? Colors.white54
                                : const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(1);
                setState(() => _selectedTabIndex = 1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? (isDark ? const Color(0xFF334155) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _selectedTabIndex == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_outlined,
                      size: 16,
                      color: _selectedTabIndex == 1
                          ? (isDark ? Colors.white : brandPrimary)
                          : (isDark ? Colors.white54 : const Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Registrarse',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: _selectedTabIndex == 1
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: _selectedTabIndex == 1
                            ? (isDark ? Colors.white : brandPrimary)
                            : (isDark
                                ? Colors.white54
                                : const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(bool isDark) {
    return FadeInUp(
      duration: const Duration(milliseconds: 450),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 13,
                color:
                    isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 5),
              Text(
                'Datos cifrados y almacenados de forma segura',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

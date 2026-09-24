import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../auth/presentation/screens/auth_screen.dart';
import '../../../perfil/presentation/providers/perfil_provider.dart';
import '../../../perfil/presentation/screens/registro_perfil_screen.dart';
import '../../../registros/presentation/providers/registro_provider.dart';
import 'home_navigation_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navegarSiguiente();
  }

  Future<void> _navegarSiguiente() async {
    await Future.delayed(const Duration(milliseconds: 1600));
    if (!mounted) return;

    final storage = ref.read(sessionStorageProvider);
    final hasSession = storage.hasSession();

    Widget destino;

    if (hasSession) {
      try {
        await ref.read(perfilNotifierProvider.notifier).cargarPerfil();
        await ref.read(registrosNotifierProvider.notifier).cargarRegistros();
        final perfil = ref.read(perfilNotifierProvider).value;

        final bool estaCompletado = storage.isPerfilCompletado() || (perfil?.perfilCompletado ?? false);
        destino = estaCompletado ? const HomeNavigationScreen() : const RegistroPerfilScreen();
      } catch (_) {
        destino = const HomeNavigationScreen();
      }
    } else {
      destino = const AuthScreen();
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destino,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF0B0F19),
                    const Color(0xFF1E1B4B),
                    const Color(0xFF0F172A),
                  ]
                : [
                    const Color(0xFF4F46E5),
                    const Color(0xFF4338CA),
                    const Color(0xFF3730A3),
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ZoomIn(
                duration: const Duration(milliseconds: 700),
                child: Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withValues(alpha: 0.35),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFF4F46E5),
                          child: const Center(
                            child: Icon(
                              Icons.timer_outlined,
                              size: 54,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeInDown(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
                child: Text(
                  AppConstants.appName,
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 350),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Control Inteligente de Prácticas',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              FadeIn(
                duration: const Duration(milliseconds: 500),
                delay: const Duration(milliseconds: 500),
                child: Column(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sincronizado con Servidor Cloud',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

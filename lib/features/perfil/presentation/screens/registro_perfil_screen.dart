import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:practi_horas_app/core/di/dependency_injection.dart';
import 'package:practi_horas_app/core/router/app_routes.dart';
import 'package:practi_horas_app/core/shared_atomic/atoms/custom_button.dart';
import 'package:practi_horas_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:practi_horas_app/features/perfil/presentation/providers/onboarding_wizard_provider.dart';
import 'package:practi_horas_app/features/perfil/presentation/providers/perfil_provider.dart';
import 'package:practi_horas_app/features/perfil/presentation/widgets/wizard/step_convenio_widget.dart';
import 'package:practi_horas_app/features/perfil/presentation/widgets/wizard/step_horario_widget.dart';
import 'package:practi_horas_app/features/perfil/presentation/widgets/wizard/step_periodo_widget.dart';
import 'package:practi_horas_app/features/perfil/presentation/widgets/wizard/wizard_progress_header.dart';

class RegistroPerfilScreen extends ConsumerStatefulWidget {
  const RegistroPerfilScreen({super.key});

  @override
  ConsumerState<RegistroPerfilScreen> createState() =>
      _RegistroPerfilScreenState();
}

class _RegistroPerfilScreenState extends ConsumerState<RegistroPerfilScreen> {
  late PageController _pageController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Precargar nombre registrado si existe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessionName = ref.read(sessionStorageProvider).getUserName();
      if (sessionName != null && sessionName.trim().isNotEmpty) {
        ref.read(onboardingWizardProvider.notifier).setNombre(sessionName.trim());
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    final state = ref.read(onboardingWizardProvider);
    final notifier = ref.read(onboardingWizardProvider.notifier);

    // Validar en el paso 0
    if (state.currentStep == 0) {
      if (state.metaHorasTotal <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La meta de horas debe ser mayor a 0.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
    }

    if (state.currentStep < 2) {
      notifier.nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _onBack() {
    final state = ref.read(onboardingWizardProvider);
    final notifier = ref.read(onboardingWizardProvider.notifier);

    if (state.currentStep > 0) {
      notifier.prevStep();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _finalizarOnboarding() async {
    final notifier = ref.read(onboardingWizardProvider.notifier);
    final perfil = notifier.buildPerfilFinal();

    setState(() => _isLoading = true);

    try {
      await ref.read(perfilNotifierProvider.notifier).guardarPerfilInicial(
            nombre: perfil.nombre,
            metaHoras: perfil.metaHorasTotal,
            horasInicialesPrevias: perfil.horasInicialesPrevias,
            horasMinimasSemanales: perfil.horasMinimasSemanales,
            fechaInicio: perfil.fechaInicio,
            fechaFin: perfil.fechaFin,
            horarioSemanal: perfil.horarioSemanal,
          );

      // Invalidar métricas de dashboard para recálculo inmediato con la nueva fechaFin
      ref.invalidate(dashboardMetricsProvider);

      if (!mounted) return;

      context.go(AppRoutes.home);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar perfil: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wizardState = ref.watch(onboardingWizardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Header con logo y marca
            FadeInDown(
              duration: const Duration(milliseconds: 350),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.schedule_rounded,
                          size: 18,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'PractiHoras',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),

            // Header de Progreso y Pasos
            WizardProgressHeader(
              currentStep: wizardState.currentStep,
              totalSteps: 3,
              onBack: _onBack,
            ),

            // Contenido Dinámico de Pasos en PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: const [
                  StepConvenioWidget(),
                  StepPeriodoWidget(),
                  StepHorarioWidget(),
                ],
              ),
            ),

            // Barra Inferior de Acción
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: Border(
                  top: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (wizardState.currentStep > 0) ...[
                    CustomButton(
                      text: 'Atrás',
                      variant: ButtonVariant.outline,
                      width: 100,
                      onPressed: _isLoading ? null : _onBack,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: CustomButton(
                      text: wizardState.currentStep == 2
                          ? '¡Comenzar ahora! 🚀'
                          : 'Continuar →',
                      isLoading: _isLoading,
                      onPressed: _isLoading
                          ? null
                          : (wizardState.currentStep == 2
                              ? _finalizarOnboarding
                              : _onNext),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

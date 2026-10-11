import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practi_horas_app/core/utils/date_formatters.dart';
import 'package:practi_horas_app/features/perfil/presentation/providers/onboarding_wizard_provider.dart';

class StepPeriodoWidget extends ConsumerWidget {
  const StepPeriodoWidget({super.key});

  Future<void> _seleccionarFechaInicio(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final state = ref.read(onboardingWizardProvider);
    final notifier = ref.read(onboardingWizardProvider.notifier);
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: state.fechaInicio,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
      locale: const Locale('es', 'ES'),
      helpText: 'Fecha de Inicio de Prácticas',
      confirmText: 'Aceptar',
      cancelText: 'Cancelar',
    );

    if (picked != null) {
      notifier.setFechaInicio(picked);
    }
  }

  Future<void> _seleccionarFechaFin(BuildContext context, WidgetRef ref) async {
    final state = ref.read(onboardingWizardProvider);
    final notifier = ref.read(onboardingWizardProvider.notifier);

    final initial = state.fechaFin.isAfter(state.fechaInicio)
        ? state.fechaFin
        : state.fechaInicio.add(const Duration(days: 30));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: state.fechaInicio,
      lastDate: DateTime(state.fechaInicio.year + 5),
      locale: const Locale('es', 'ES'),
      helpText: 'Fecha Límite / Fin de Prácticas',
      confirmText: 'Aceptar',
      cancelText: 'Cancelar',
    );

    if (picked != null) {
      notifier.setFechaFin(picked);
    }
  }

  Widget _buildFechaCard({
    required BuildContext context,
    required String titulo,
    required String fechaStr,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryColor,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: primaryColor),
                    const SizedBox(width: 6),
                    Text(
                      titulo,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white54
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  fechaStr,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Toca para cambiar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 20,
              color: primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingWizardProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    final fechaInicioStr = DateFormatters.fechaCorta(state.fechaInicio);
    final fechaFinStr = DateFormatters.fechaCorta(state.fechaFin);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Período de tus prácticas',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),

          // Selectores lado a lado: Inicio y Fin
          Column(
            children: [
              _buildFechaCard(
                context: context,
                titulo: 'Fecha Inicio',
                fechaStr: fechaInicioStr,
                icon: Icons.play_circle_outline_rounded,
                onTap: () => _seleccionarFechaInicio(context, ref),
                isDark: isDark,
                primaryColor: primaryColor,
              ),
              const SizedBox(height: 10),
              _buildFechaCard(
                context: context,
                titulo: 'Fecha Límite (Fin)',
                fechaStr: fechaFinStr,
                icon: Icons.flag_outlined,
                onTap: () => _seleccionarFechaFin(context, ref),
                isDark: isDark,
                primaryColor: primaryColor,
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

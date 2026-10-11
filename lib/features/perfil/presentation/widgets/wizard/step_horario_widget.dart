import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practi_horas_app/core/utils/app_time_picker.dart';
import 'package:practi_horas_app/core/utils/date_formatters.dart';
import 'package:practi_horas_app/core/utils/time_calculator.dart';
import 'package:practi_horas_app/features/perfil/domain/entities/horario_dia.dart';
import 'package:practi_horas_app/features/perfil/presentation/providers/onboarding_wizard_provider.dart';

class StepHorarioWidget extends ConsumerStatefulWidget {
  const StepHorarioWidget({super.key});

  @override
  ConsumerState<StepHorarioWidget> createState() => _StepHorarioWidgetState();
}

class _StepHorarioWidgetState extends ConsumerState<StepHorarioWidget> {
  bool _mostrarAjusteDetallado = false;

  Widget _buildPresetCard({
    required String titulo,
    required String detalle,
    required String horasBadge,
    required HorarioPresetType type,
    required HorarioPresetType currentType,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryColor,
  }) {
    final isSelected = currentType == type;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withValues(alpha: isDark ? 0.2 : 0.08)
              : (isDark ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSelected ? Icons.check_rounded : Icons.schedule_rounded,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : const Color(0xFF64748B)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detalle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white54 : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withValues(alpha: 0.15)
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                horasBadge,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? primaryColor : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editarHorasDia(String diaKey, HorarioDia horario) async {
    final notifier = ref.read(onboardingWizardProvider.notifier);
    final initialStart = TimeCalculator.parseTimeOfDay(horario.horaInicio);

    final pickedStart = await AppTimePicker.show(
      context: context,
      initialTime: initialStart,
      title: 'Hora Entrada - ${DateFormatters.getDiaNombre(diaKey)}',
    );

    if (pickedStart != null && mounted) {
      final initialEnd = TimeCalculator.parseTimeOfDay(horario.horaFin);
      final pickedEnd = await AppTimePicker.show(
        context: context,
        initialTime: initialEnd,
        title: 'Hora Salida - ${DateFormatters.getDiaNombre(diaKey)}',
      );

      if (pickedEnd != null) {
        final startStr = TimeCalculator.formatTimeOfDay(pickedStart);
        final endStr = TimeCalculator.formatTimeOfDay(pickedEnd);
        final updated = horario.copyWith(
          horaInicio: startStr,
          horaFin: endStr,
          activo: true,
        );
        notifier.actualizarDia(diaKey, updated);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingWizardProvider);
    final notifier = ref.read(onboardingWizardProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    const diasKeys = ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Elige la plantilla que mejor se adapte',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 10),

          // 1. Mañana 4h: 08:00 AM - 12:00 PM (20h/sem)
          _buildPresetCard(
            titulo: 'Turno Mañana (4 horas/día)',
            detalle: 'Lun a Vie • 08:00 AM a 12:00 PM',
            horasBadge: '20 h/sem',
            type: HorarioPresetType.matutino,
            currentType: state.presetType,
            isDark: isDark,
            primaryColor: primaryColor,
            onTap: () => notifier.aplicarPreset(HorarioPresetType.matutino),
          ),
          const SizedBox(height: 10),

          // 2. Tarde 4h: 02:00 PM - 06:00 PM (20h/sem)
          _buildPresetCard(
            titulo: 'Turno Tarde (4 horas/día)',
            detalle: 'Lun a Vie • 02:00 PM a 06:00 PM (14:00 - 18:00)',
            horasBadge: '20 h/sem',
            type: HorarioPresetType.vespertino,
            currentType: state.presetType,
            isDark: isDark,
            primaryColor: primaryColor,
            onTap: () => notifier.aplicarPreset(HorarioPresetType.vespertino),
          ),
          const SizedBox(height: 10),

          // 3. Jornada Completa: 08:00 AM - 06:00 PM con 2 horas de refrigerio (12:00 - 02:00 PM) = 8h netas/día (40h/sem)
          _buildPresetCard(
            titulo: 'Jornada Completa (8 horas netas/día)',
            detalle: 'Lun a Vie • 08:00 AM a 06:00 PM (Descanso 12:00 - 02:00 PM)',
            horasBadge: '40 h/sem',
            type: HorarioPresetType.completa,
            currentType: state.presetType,
            isDark: isDark,
            primaryColor: primaryColor,
            onTap: () => notifier.aplicarPreset(HorarioPresetType.completa),
          ),
          const SizedBox(height: 18),

          // Ajuste fino / personalizar días
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              setState(() => _mostrarAjusteDetallado = !_mostrarAjusteDetallado);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Row(
                children: [
                  Icon(
                    _mostrarAjusteDetallado
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    color: primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Personalizar días individuales o descansos',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_mostrarAjusteDetallado) ...[
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: diasKeys.map((key) {
                  final dia = state.horarioSemanal[key] ?? HorarioDia.porDefecto(key);
                  final nombre = DateFormatters.getDiaNombre(key);

                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    title: Text(
                      nombre,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: dia.activo
                            ? (isDark ? Colors.white : const Color(0xFF0F172A))
                            : Colors.grey,
                      ),
                    ),
                    subtitle: dia.activo
                        ? Text(
                            dia.refrigerioMinutos > 0
                                ? '${dia.horaInicio} - ${dia.horaFin} (${dia.horasEfectivas}h netas, ${dia.refrigerioMinutos}m receso)'
                                : '${dia.horaInicio} - ${dia.horaFin} (${dia.horasEfectivas}h)',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : const Color(0xFF64748B),
                            ),
                          )
                        : Text(
                            'No laborable',
                            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey),
                          ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (dia.activo)
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            onPressed: () => _editarHorasDia(key, dia),
                          ),
                        Switch(
                          value: dia.activo,
                          activeTrackColor: primaryColor,
                          onChanged: (val) {
                            notifier.actualizarDia(key, dia.copyWith(activo: val));
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

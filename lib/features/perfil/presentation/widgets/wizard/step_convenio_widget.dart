import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practi_horas_app/features/perfil/presentation/providers/onboarding_wizard_provider.dart';

class StepConvenioWidget extends ConsumerStatefulWidget {
  const StepConvenioWidget({super.key});

  @override
  ConsumerState<StepConvenioWidget> createState() => _StepConvenioWidgetState();
}

class _StepConvenioWidgetState extends ConsumerState<StepConvenioWidget> {
  late TextEditingController _horasMinimasCtrl;
  late TextEditingController _horasPreviasCtrl;
  late TextEditingController _metaPersonalizadaCtrl;
  bool _mostrarMetaPersonalizada = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingWizardProvider);
    _horasMinimasCtrl = TextEditingController(
      text: state.horasMinimasSemanalesPersonalizadas != null
          ? state.horasMinimasSemanalesPersonalizadas!.toInt().toString()
          : '',
    );
    _horasPreviasCtrl = TextEditingController(
      text: state.horasInicialesPrevias > 0
          ? state.horasInicialesPrevias.toInt().toString()
          : '',
    );
    _metaPersonalizadaCtrl = TextEditingController();

    final metasEstandar = [360.0, 480.0, 600.0];
    if (!metasEstandar.contains(state.metaHorasTotal)) {
      _mostrarMetaPersonalizada = true;
      _metaPersonalizadaCtrl.text = state.metaHorasTotal.toInt().toString();
    }
  }

  @override
  void dispose() {
    _horasMinimasCtrl.dispose();
    _horasPreviasCtrl.dispose();
    _metaPersonalizadaCtrl.dispose();
    super.dispose();
  }

  Widget _buildMetaChip({
    required double horas,
    required String label,
    required String subtitulo,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryColor,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withValues(alpha: isDark ? 0.2 : 0.1)
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? primaryColor
                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitulo,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white54 : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingWizardProvider);
    final notifier = ref.read(onboardingWizardProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección 1: Meta de Horas Total
          Text(
            'Meta total de horas de prácticas',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildMetaChip(
                horas: 360,
                label: '360 h',
                subtitulo: 'Estándar',
                isSelected: state.metaHorasTotal == 360 && !_mostrarMetaPersonalizada,
                isDark: isDark,
                primaryColor: primaryColor,
                onTap: () {
                  setState(() => _mostrarMetaPersonalizada = false);
                  notifier.setMetaHoras(360);
                },
              ),
              const SizedBox(width: 8),
              _buildMetaChip(
                horas: 480,
                label: '480 h',
                subtitulo: 'Semestral',
                isSelected: state.metaHorasTotal == 480 && !_mostrarMetaPersonalizada,
                isDark: isDark,
                primaryColor: primaryColor,
                onTap: () {
                  setState(() => _mostrarMetaPersonalizada = false);
                  notifier.setMetaHoras(480);
                },
              ),
              const SizedBox(width: 8),
              _buildMetaChip(
                horas: 600,
                label: '600 h',
                subtitulo: 'Anual',
                isSelected: state.metaHorasTotal == 600 && !_mostrarMetaPersonalizada,
                isDark: isDark,
                primaryColor: primaryColor,
                onTap: () {
                  setState(() => _mostrarMetaPersonalizada = false);
                  notifier.setMetaHoras(600);
                },
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Opción Meta Personalizada
          InkWell(
            onTap: () {
              setState(() => _mostrarMetaPersonalizada = !_mostrarMetaPersonalizada);
            },
            child: Row(
              children: [
                Icon(
                  _mostrarMetaPersonalizada
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 18,
                  color: _mostrarMetaPersonalizada ? primaryColor : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  'Tengo otra cantidad de horas requeridas',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _mostrarMetaPersonalizada
                        ? primaryColor
                        : (isDark ? Colors.white70 : const Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          ),
          if (_mostrarMetaPersonalizada) ...[
            const SizedBox(height: 8),
            TextFormField(
              controller: _metaPersonalizadaCtrl,
              keyboardType: TextInputType.number,
              onChanged: (val) {
                final d = double.tryParse(val);
                if (d != null && d > 0) {
                  notifier.setMetaHoras(d);
                }
              },
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'Ingresa tus horas meta (ej. 400)',
                suffixText: 'horas',
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
            ),
          ],

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // Sección 2: Mínimo de Horas Semanales (Personalizado y Opcional)
          Text(
            'Mínimo de horas semanales a cumplir (Opcional)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Si tu convenio o universidad exige un mínimo semanal fijo (ej. 20 hrs), ingrésalo aquí. Si lo dejas vacío, se calculará según tu horario.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: isDark ? Colors.white54 : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _horasMinimasCtrl,
            keyboardType: TextInputType.number,
            onChanged: (val) {
              final d = double.tryParse(val.trim());
              notifier.setHorasMinimasSemanales(d);
            },
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              hintText: 'Ej. 20',
              suffixText: 'hrs / semana',
              prefixIcon: const Icon(Icons.timer_outlined, size: 20),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // Sección 3: Switch de Horas Previas
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¿Ya iniciaste antes de usar la app?',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Para sumar tus horas ya acumuladas',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: isDark ? Colors.white54 : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: state.yaInicioHoras,
                      activeTrackColor: primaryColor,
                      onChanged: (val) {
                        notifier.setYaInicioHoras(val);
                      },
                    ),
                  ],
                ),
                if (state.yaInicioHoras) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _horasPreviasCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final h = double.tryParse(val) ?? 0.0;
                      notifier.setHorasPrevias(h);
                    },
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Horas ya cursadas (ej. 50)',
                      suffixText: 'horas',
                      prefixIcon: const Icon(Icons.history_rounded, size: 20),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

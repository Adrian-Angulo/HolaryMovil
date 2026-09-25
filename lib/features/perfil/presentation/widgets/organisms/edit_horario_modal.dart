import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:practi_horas_app/core/constants/app_constants.dart';
import 'package:practi_horas_app/core/utils/date_formatters.dart';
import 'package:practi_horas_app/core/utils/time_calculator.dart';
import 'package:practi_horas_app/features/perfil/domain/entities/horario_dia.dart';

class EditHorarioModal extends StatefulWidget {
  final String diaKey;
  final HorarioDia horario;
  final Future<void> Function(HorarioDia updated) onSave;

  const EditHorarioModal({
    super.key,
    required this.diaKey,
    required this.horario,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required String diaKey,
    required HorarioDia horario,
    required Future<void> Function(HorarioDia updated) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditHorarioModal(
        diaKey: diaKey,
        horario: horario,
        onSave: onSave,
      ),
    );
  }

  @override
  State<EditHorarioModal> createState() => _EditHorarioModalState();
}

class _EditHorarioModalState extends State<EditHorarioModal> {
  late bool _activo;
  late String _horaInicio;
  late String _horaFin;
  late String _modalidad;
  late int _refrigerioMinutos;
  late final TextEditingController _refrigerioController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _activo = widget.horario.activo;
    _horaInicio = widget.horario.horaInicio;
    _horaFin = widget.horario.horaFin;
    _modalidad = widget.horario.modalidad;
    _refrigerioMinutos = widget.horario.refrigerioMinutos;
    _refrigerioController = TextEditingController(
      text: _refrigerioMinutos > 0 ? _refrigerioMinutos.toString() : '0',
    );
  }

  @override
  void dispose() {
    _refrigerioController.dispose();
    super.dispose();
  }

  double get _horasCalculadas => TimeCalculator.calcularHorasNetas(
        _horaInicio,
        _horaFin,
        _refrigerioMinutos,
      );

  Future<void> _submit() async {
    setState(() => _isSaving = true);
    final updated = widget.horario.copyWith(
      activo: _activo,
      horaInicio: _horaInicio,
      horaFin: _horaFin,
      refrigerioMinutos: _refrigerioMinutos,
      modalidad: _modalidad,
    );
    await widget.onSave(updated);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final diaNombre = DateFormatters.getDiaNombre(widget.diaKey);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.access_time_rounded,
                    color: Color(0xFF4F46E5),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Horario de $diaNombre',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Jornada y tiempo de descanso / comida',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '¿Día laboral activo?',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              subtitle: Text(
                _activo
                    ? 'Este día se contabiliza en tu plan semanal'
                    : 'Día de descanso o sin jornada',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                ),
              ),
              value: _activo,
              activeTrackColor: const Color(0xFF10B981),
              onChanged: (val) => setState(() => _activo = val),
            ),
            if (_activo) ...[
              const SizedBox(height: 12),
              // Entrada y Salida
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: InkWell(
                        onTap: () async {
                          final initial = TimeCalculator.parseTimeOfDay(_horaInicio);
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: initial,
                          );
                          if (picked != null) {
                            setState(() {
                              _horaInicio = TimeCalculator.formatTimeOfDay(picked);
                            });
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hora Entrada',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _horaInicio,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: InkWell(
                        onTap: () async {
                          final initial = TimeCalculator.parseTimeOfDay(_horaFin);
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: initial,
                          );
                          if (picked != null) {
                            setState(() {
                              _horaFin = TimeCalculator.formatTimeOfDay(picked);
                            });
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hora Salida',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _horaFin,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Campo de Texto para Descanso / Comida
              Text(
                'Minutos de descanso / comida (no computables)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _refrigerioController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: 'Ej. 45 (o 0 si no hay descanso)',
                  prefixIcon: const Icon(
                    Icons.free_breakfast_outlined,
                    size: 20,
                    color: Color(0xFFF59E0B),
                  ),
                  suffixText: 'minutos',
                  suffixStyle: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFF59E0B),
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 1.6),
                  ),
                ),
                onChanged: (val) {
                  final parsed = int.tryParse(val.trim()) ?? 0;
                  setState(() {
                    _refrigerioMinutos = parsed >= 0 ? parsed : 0;
                  });
                },
              ),
              const SizedBox(height: 14),
              // Modalidad
              Text(
                'Modalidad',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: AppConstants.modalidades.map((mod) {
                  final isSelected = _modalidad == mod;
                  return ChoiceChip(
                    label: Text(mod),
                    selected: isSelected,
                    selectedColor: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF4F46E5)
                          : (isDark ? Colors.white70 : const Color(0xFF475569)),
                    ),
                    onSelected: (_) => setState(() => _modalidad = mod),
                  );
                }).toList(),
              ),
              const SizedBox(height: 14),
              // Tarjeta Resumen de Horas Efectivas
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Horas efectivas netas para este día:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                        ),
                      ),
                    ),
                    Text(
                      '${_horasCalculadas.toStringAsFixed(1)} hrs',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Guardar Horario',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

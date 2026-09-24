import 'package:flutter/material.dart';
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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _activo = widget.horario.activo;
    _horaInicio = widget.horario.horaInicio;
    _horaFin = widget.horario.horaFin;
    _modalidad = widget.horario.modalidad;
  }

  Future<void> _submit() async {
    setState(() => _isSaving = true);
    final updated = widget.horario.copyWith(
      activo: _activo,
      horaInicio: _horaInicio,
      horaFin: _horaFin,
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
                      'Personaliza tu jornada para este día',
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
                  ? 'Este día se contabiliza en tu semana'
                  : 'Día de descanso o no programado',
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
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Hora Inicio',
                      style: TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(
                      _horaInicio,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                  ),
                ),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text(
                      'Hora Fin',
                      style: TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(
                      _horaFin,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Modalidad', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: AppConstants.modalidades.map((mod) {
                return ChoiceChip(
                  label: Text(mod),
                  selected: _modalidad == mod,
                  selectedColor: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                  onSelected: (_) => setState(() => _modalidad = mod),
                );
              }).toList(),
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
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:practi_horas_app/core/utils/date_formatters.dart';
import 'package:practi_horas_app/features/perfil/domain/entities/perfil.dart';

class EditPeriodoModal extends StatefulWidget {
  final Perfil perfil;
  final Future<void> Function({
    required DateTime? fechaInicio,
    required DateTime? fechaFin,
  }) onSave;

  const EditPeriodoModal({
    super.key,
    required this.perfil,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required Perfil perfil,
    required Future<void> Function({
      required DateTime? fechaInicio,
      required DateTime? fechaFin,
    }) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditPeriodoModal(perfil: perfil, onSave: onSave),
    );
  }

  @override
  State<EditPeriodoModal> createState() => _EditPeriodoModalState();
}

class _EditPeriodoModalState extends State<EditPeriodoModal> {
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fechaInicio = widget.perfil.fechaInicio;
    _fechaFin = widget.perfil.fechaFin;
  }

  Future<void> _submit() async {
    setState(() => _isSaving = true);
    await widget.onSave(fechaInicio: _fechaInicio, fechaFin: _fechaFin);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  color: const Color(0xFF0284C7).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xFF0284C7),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Período de Prácticas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Fechas de inicio y fin para calcular tu ritmo',
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
          const SizedBox(height: 20),
          Text(
            'Fecha de Inicio:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _fechaInicio ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) {
                setState(() => _fechaInicio = picked);
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_available_rounded,
                      size: 20, color: Color(0xFF4F46E5)),
                  const SizedBox(width: 12),
                  Text(
                    _fechaInicio != null
                        ? DateFormatters.fechaCompleta(_fechaInicio!)
                        : 'Seleccionar fecha de inicio',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: _fechaInicio != null
                          ? (isDark ? Colors.white : const Color(0xFF0F172A))
                          : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Fecha de Fin / Término:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _fechaFin ??
                    (_fechaInicio != null
                        ? _fechaInicio!.add(const Duration(days: 90))
                        : DateTime.now()),
                firstDate: _fechaInicio ?? DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) {
                setState(() => _fechaFin = picked);
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_busy_rounded,
                      size: 20, color: Color(0xFF0284C7)),
                  const SizedBox(width: 12),
                  Text(
                    _fechaFin != null
                        ? DateFormatters.fechaCompleta(_fechaFin!)
                        : 'Seleccionar fecha de término',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: _fechaFin != null
                          ? (isDark ? Colors.white : const Color(0xFF0F172A))
                          : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0284C7),
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
                      'Guardar Fechas',
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

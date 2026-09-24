import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:practi_horas_app/features/perfil/domain/entities/perfil.dart';

class EditMetasModal extends StatefulWidget {
  final Perfil perfil;
  final Future<void> Function({
    required double metaHoras,
    required double horasMinimasSemanales,
    required double horasInicialesPrevias,
  }) onSave;

  const EditMetasModal({
    super.key,
    required this.perfil,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required Perfil perfil,
    required Future<void> Function({
      required double metaHoras,
      required double horasMinimasSemanales,
      required double horasInicialesPrevias,
    }) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditMetasModal(perfil: perfil, onSave: onSave),
    );
  }

  @override
  State<EditMetasModal> createState() => _EditMetasModalState();
}

class _EditMetasModalState extends State<EditMetasModal> {
  late final TextEditingController _metaController;
  late final TextEditingController _minimasController;
  late final TextEditingController _previasController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _metaController = TextEditingController(
      text: widget.perfil.metaHorasTotal.toStringAsFixed(0),
    );
    _minimasController = TextEditingController(
      text: widget.perfil.horasMinimasSemanales.toStringAsFixed(0),
    );
    _previasController = TextEditingController(
      text: widget.perfil.horasInicialesPrevias.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _metaController.dispose();
    _minimasController.dispose();
    _previasController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final meta = double.tryParse(_metaController.text.trim()) ??
        widget.perfil.metaHorasTotal;
    final minimas = double.tryParse(_minimasController.text.trim()) ??
        widget.perfil.horasMinimasSemanales;
    final previas = double.tryParse(_previasController.text.trim()) ??
        widget.perfil.horasInicialesPrevias;

    setState(() => _isSaving = true);
    await widget.onSave(
      metaHoras: meta,
      horasMinimasSemanales: minimas,
      horasInicialesPrevias: previas,
    );

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
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.flag_rounded,
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
                      'Editar Metas y Horas',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Ajusta los objetivos de tu convenio de prácticas',
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
            'Meta Total de Horas:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _metaController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: _inputDecoration(
              hintText: 'Ej. 360 o 480',
              suffixText: 'horas',
              prefixIcon: Icons.track_changes_rounded,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Mínimo de Horas Semanales:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _minimasController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: _inputDecoration(
              hintText: 'Ej. 30',
              suffixText: 'hrs/sem',
              prefixIcon: Icons.view_week_rounded,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Horas Ya Cursadas / Convalidadas:',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _previasController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: _inputDecoration(
              hintText: 'Ej. 0 o 45.5',
              suffixText: 'horas',
              prefixIcon: Icons.history_edu_rounded,
              isDark: isDark,
            ),
          ),
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
                      'Guardar Metas',
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

  InputDecoration _inputDecoration({
    required String hintText,
    required String suffixText,
    required IconData prefixIcon,
    required bool isDark,
  }) {
    return InputDecoration(
      hintText: hintText,
      suffixText: suffixText,
      prefixIcon: Icon(prefixIcon, size: 20),
      filled: true,
      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}

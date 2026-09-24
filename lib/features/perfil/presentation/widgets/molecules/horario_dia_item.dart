import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:practi_horas_app/core/utils/date_formatters.dart';
import 'package:practi_horas_app/features/perfil/domain/entities/horario_dia.dart';

class HorarioDiaItem extends StatelessWidget {
  final String diaKey;
  final HorarioDia horario;
  final VoidCallback onTap;
  final bool isDark;

  const HorarioDiaItem({
    super.key,
    required this.diaKey,
    required this.horario,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: horario.activo
            ? (isDark
                ? const Color(0xFF334155).withValues(alpha: 0.4)
                : const Color(0xFFEEF2FF))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: horario.activo
                ? const Color(0xFF4F46E5)
                : (isDark ? Colors.white10 : Colors.grey.shade200),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            DateFormatters.getDiaNombre(diaKey).substring(0, 2).toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: horario.activo
                  ? Colors.white
                  : (isDark ? Colors.white54 : Colors.grey.shade600),
            ),
          ),
        ),
        title: Text(
          DateFormatters.getDiaNombre(diaKey),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          horario.activo
              ? '${horario.horaInicio} - ${horario.horaFin} • ${horario.modalidad}'
              : 'Día no laboral / descanso',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: horario.activo
                ? (isDark ? const Color(0xFF94A3B8) : const Color(0xFF4F46E5))
                : Colors.grey,
          ),
        ),
        trailing: Icon(
          Icons.edit_outlined,
          size: 18,
          color: isDark ? Colors.white54 : const Color(0xFF64748B),
        ),
        onTap: onTap,
      ),
    );
  }
}

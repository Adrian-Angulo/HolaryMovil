import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practi_horas_app/core/shared_atomic/atoms/custom_card.dart';
import 'package:practi_horas_app/features/perfil/domain/entities/horario_dia.dart';

class HorarioHoyCard extends StatelessWidget {
  final HorarioDia? horarioHoy;
  final VoidCallback? onEditarHorario;

  const HorarioHoyCard({
    super.key,
    required this.horarioHoy,
    this.onEditarHorario,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    final estaHabilitado = horarioHoy?.habilitado ?? false;

    return CustomCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.schedule_rounded,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Horario para Hoy',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              if (onEditarHorario != null)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  onPressed: onEditarHorario,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  tooltip: 'Editar horario',
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (estaHabilitado && horarioHoy != null) ...[
            Row(
              children: [
                Expanded(
                  child: _buildTimeChip(
                    context,
                    label: 'Entrada',
                    time: horarioHoy!.horaEntrada,
                    icon: Icons.login_rounded,
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildTimeChip(
                    context,
                    label: 'Salida',
                    time: horarioHoy!.horaSalida,
                    icon: Icons.logout_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
            if (horarioHoy!.minutosColacion > 0) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.restaurant_rounded, size: 14, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Text(
                    'Colación: ${horarioHoy!.minutosColacion} min',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Total jornada: ${horarioHoy!.horasEfectivas.toStringAsFixed(1)}h',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.weekend_outlined,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Día libre o sin horario asignado',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeChip(
    BuildContext context, {
    required String label,
    required String time,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

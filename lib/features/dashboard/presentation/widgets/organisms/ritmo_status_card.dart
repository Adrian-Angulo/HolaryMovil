import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practi_horas_app/features/dashboard/domain/entities/metricas_dashboard.dart';
import 'package:practi_horas_app/core/shared_atomic/atoms/custom_card.dart';

class RitmoStatusCard extends StatelessWidget {
  final MetricasDashboard metricas;
  final VoidCallback? onConfigurarFechas;

  const RitmoStatusCard({
    super.key,
    required this.metricas,
    this.onConfigurarFechas,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color badgeColor;
    IconData statusIcon;
    String statusTitle;

    switch (metricas.estadoRitmo) {
      case EstadoRitmo.adelantado:
        badgeColor = const Color(0xFF10B981);
        statusIcon = Icons.rocket_launch_rounded;
        statusTitle = 'Adelantado a la Meta';
        break;
      case EstadoRitmo.aTiempo:
        badgeColor = const Color(0xFF4F46E5);
        statusIcon = Icons.check_circle_rounded;
        statusTitle = 'A Buen Ritmo';
        break;
      case EstadoRitmo.atrasado:
        badgeColor = const Color(0xFFF59E0B);
        statusIcon = Icons.timelapse_rounded;
        statusTitle = 'Ritmo Atrasado';
        break;
      case EstadoRitmo.sinFechas:
        badgeColor = const Color(0xFF64748B);
        statusIcon = Icons.event_note_rounded;
        statusTitle = 'Sin Fechas Definidas';
        break;
    }

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
                      color: badgeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(statusIcon, color: badgeColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estado de Cumplimiento',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        statusTitle,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (metricas.estadoRitmo != EstadoRitmo.sinFechas)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    metricas.diferenciaHorasRitmo >= 0
                        ? '+${metricas.diferenciaHorasRitmo}h'
                        : '${metricas.diferenciaHorasRitmo}h',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            metricas.mensajeRitmo,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? const Color(0xFFE2E8F0)
                  : const Color(0xFF334155),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          if (metricas.estadoRitmo != EstadoRitmo.sinFechas) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (metricas.diasHabilesRestantes > 0 &&
                    metricas.horasRestantes > 0)
                  _buildPill(
                    context,
                    icon: Icons.speed_rounded,
                    label:
                        'Meta diaria: ${metricas.ritmoDiarioSugerido}h/día',
                    color: const Color(0xFF06B6D4),
                  ),
                if (metricas.diasHabilesRestantes > 0)
                  _buildPill(
                    context,
                    icon: Icons.date_range_rounded,
                    label:
                        '${metricas.diasHabilesRestantes} días hábiles restantes',
                    color: const Color(0xFF10B981),
                  ),
              ],
            ),
          ] else if (onConfigurarFechas != null) ...[
            OutlinedButton.icon(
              onPressed: onConfigurarFechas,
              icon: const Icon(Icons.tune_rounded, size: 16),
              label: const Text('Configurar Fechas de Prácticas'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.15)
            : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : color,
            ),
          ),
        ],
      ),
    );
  }
}

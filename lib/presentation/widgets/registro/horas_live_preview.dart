import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practi_horas_app/core/utils/time_calculator.dart';
import '../common/custom_card.dart';

class HorasLivePreview extends StatelessWidget {
  final String horaInicio;
  final String horaFin;
  final double horasComputables;

  const HorasLivePreview({
    super.key,
    required this.horaInicio,
    required this.horaFin,
    required this.horasComputables,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      backgroundColor: isDark
          ? const Color(0xFF1E293B)
          : const Color(0xFFEEF2FF), // Indigo 50
      border: Border.all(
        color: isDark ? const Color(0xFF3730A3) : const Color(0xFFC7D2FE),
        width: 1.5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Computable',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$horasComputables',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'horas',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(
                  TimeCalculator.formatHorasHumanReadable(horasComputables),
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

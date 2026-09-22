import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:practi_horas_app/core/utils/date_formatters.dart';
import '../common/custom_card.dart';

class ChartSemanal extends StatelessWidget {
  final Map<int, double> horasPorDiaSemana; // 1 (Lun) a 7 (Dom)
  final double horasEstaSemana;

  const ChartSemanal({
    super.key,
    required this.horasPorDiaSemana,
    required this.horasEstaSemana,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Calcular máximo para el eje Y (mínimo 8 para buen aspecto)
    double maxHoras = 8.0;
    for (final h in horasPorDiaSemana.values) {
      if (h > maxHoras) maxHoras = h;
    }
    maxHoras = (maxHoras + 2).ceilToDouble();

    return CustomCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rendimiento Semanal',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Lunes a Domingo (Semana Actual)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$horasEstaSemana hrs',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxHoras,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final dia = DateFormatters.getDiaAbbr(group.x.toInt());
                      return BarTooltipItem(
                        '$dia\n',
                        GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: '${rod.toY.toStringAsFixed(1)} hrs',
                            style: GoogleFonts.inter(
                              color: const Color(0xFF34D399),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final diaText = DateFormatters.getDiaAbbr(value.toInt());
                        final hoyWeekday = DateTime.now().weekday;
                        final esHoy = value.toInt() == hoyWeekday;

                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 6,
                          child: Text(
                            diaText,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: esHoy ? FontWeight.w700 : FontWeight.w500,
                              color: esHoy
                                  ? primaryColor
                                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: maxHoras > 10 ? 4 : 2,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          '${value.toInt()}h',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxHoras > 10 ? 4 : 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(7, (index) {
                  final diaIndex = index + 1;
                  final horas = horasPorDiaSemana[diaIndex] ?? 0.0;
                  final hoyWeekday = DateTime.now().weekday;
                  final esHoy = diaIndex == hoyWeekday;

                  return BarChartGroupData(
                    x: diaIndex,
                    barRods: [
                      BarChartRodData(
                        toY: horas,
                        gradient: LinearGradient(
                          colors: esHoy
                              ? [const Color(0xFF4F46E5), const Color(0xFF818CF8)]
                              : (horas > 0
                                  ? [const Color(0xFF06B6D4), const Color(0xFF38BDF8)]
                                  : [
                                      isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                      isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                    ]),
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 14,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxHoras,
                          color: isDark
                              ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                              : const Color(0xFFF8FAFC),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

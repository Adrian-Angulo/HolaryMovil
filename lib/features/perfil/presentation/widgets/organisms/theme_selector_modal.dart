import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeSelectorModal extends StatelessWidget {
  final ThemeMode currentTheme;
  final void Function(ThemeMode mode) onSelectTheme;

  const ThemeSelectorModal({
    super.key,
    required this.currentTheme,
    required this.onSelectTheme,
  });

  static Future<void> show({
    required BuildContext context,
    required ThemeMode currentTheme,
    required void Function(ThemeMode mode) onSelectTheme,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ThemeSelectorModal(
        currentTheme: currentTheme,
        onSelectTheme: onSelectTheme,
      ),
    );
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
      padding: const EdgeInsets.only(bottom: 28, left: 24, right: 24, top: 20),
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
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.palette_outlined,
                  color: Color(0xFFF59E0B),
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tema de la Aplicación',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Elige el modo visual de la aplicación',
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
          _buildThemeOption(
            context: context,
            title: 'Modo Claro',
            subtitle: 'Colores claros y nítidos optimizados para el día',
            icon: Icons.light_mode_rounded,
            iconColor: const Color(0xFFF59E0B),
            mode: ThemeMode.light,
            isSelected: currentTheme == ThemeMode.light,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildThemeOption(
            context: context,
            title: 'Modo Oscuro',
            subtitle: 'Tonos oscuros para menor fatiga visual nocturna',
            icon: Icons.dark_mode_rounded,
            iconColor: const Color(0xFF6366F1),
            mode: ThemeMode.dark,
            isSelected: currentTheme == ThemeMode.dark,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _buildThemeOption(
            context: context,
            title: 'Predeterminado del Sistema',
            subtitle: 'Sigue automáticamente la configuración de tu dispositivo',
            icon: Icons.brightness_auto_rounded,
            iconColor: const Color(0xFF10B981),
            mode: ThemeMode.system,
            isSelected: currentTheme == ThemeMode.system,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required ThemeMode mode,
    required bool isSelected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        onSelectTheme(mode);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF334155) : const Color(0xFFEEF2FF))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF4F46E5)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.8 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF4F46E5),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

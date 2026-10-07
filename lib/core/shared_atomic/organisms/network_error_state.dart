import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Organismo visual reutilizable para presentar estados amigables cuando no hay conexión a internet.
/// Sigue las directrices de Atomic Design, Mobile UX/UI y Clean Code.
class NetworkErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final IconData icon;

  const NetworkErrorState({
    super.key,
    required this.onRetry,
    this.title = 'Sin conexión con el servidor',
    this.message =
        'No pudimos sincronizar tus datos con el servidor. Verifica tu conexión a internet o intenta nuevamente en unos momentos.',
    this.icon = Icons.wifi_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 52,
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                'Reintentar',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

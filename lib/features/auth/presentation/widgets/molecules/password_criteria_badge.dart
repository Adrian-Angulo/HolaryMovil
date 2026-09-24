import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordCriteriaBadge extends StatelessWidget {
  final String label;
  final bool isValid;
  final bool isDark;

  const PasswordCriteriaBadge({
    super.key,
    required this.label,
    required this.isValid,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        isValid ? const Color(0xFF10B981) : (isDark ? Colors.white38 : Colors.grey.shade400);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isValid
            ? const Color(0xFF10B981).withValues(alpha: 0.12)
            : (isDark ? Colors.white10 : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isValid
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : (isDark ? Colors.white12 : Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

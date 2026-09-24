import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool isDark;

  const PasswordStrengthIndicator({
    super.key,
    required this.password,
    required this.isDark,
  });

  double get _strengthScore {
    if (password.isEmpty) return 0.0;
    double score = 0.0;
    if (password.length >= 6) score += 0.35;
    if (password.length >= 8) score += 0.15;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 0.25;
    return score.clamp(0.0, 1.0);
  }

  Color get _strengthColor {
    final s = _strengthScore;
    if (s < 0.35) return const Color(0xFFEF4444);
    if (s < 0.7) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  String get _strengthText {
    final s = _strengthScore;
    if (password.isEmpty) return 'Seguridad de la clave';
    if (s < 0.35) return 'Débil (mínimo 6 caracteres)';
    if (s < 0.7) return 'Media';
    return 'Fuerte';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _strengthText,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _strengthColor,
              ),
            ),
            Text(
              '${(_strengthScore * 100).toInt()}%',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _strengthColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _strengthScore,
            backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_strengthColor),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

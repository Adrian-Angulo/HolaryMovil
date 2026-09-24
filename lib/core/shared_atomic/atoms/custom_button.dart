import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum ButtonVariant { primary, secondary, outline, text, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final ButtonVariant variant;
  final double height;
  final double? width;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.height = 50,
    this.width,
    this.borderRadius = 14,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget childContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    final style = _getButtonStyle(context, isDark);

    Widget button;
    switch (variant) {
      case ButtonVariant.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: childContent,
        );
        break;
      case ButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: childContent,
        );
        break;
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
      case ButtonVariant.danger:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: childContent,
        );
    }

    if (width != null) {
      return SizedBox(width: width, height: height, child: button);
    }

    return SizedBox(height: height, child: button);
  }

  ButtonStyle _getButtonStyle(BuildContext context, bool isDark) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
    );

    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F46E5),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: shape,
        );
      case ButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor:
              isDark ? const Color(0xFF334155) : const Color(0xFFEEF2FF),
          foregroundColor:
              isDark ? Colors.white : const Color(0xFF4338CA),
          elevation: 0,
          shape: shape,
        );
      case ButtonVariant.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: shape,
        );
      case ButtonVariant.outline:
        return OutlinedButton.styleFrom(
          foregroundColor:
              isDark ? Colors.white70 : const Color(0xFF475569),
          side: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
          ),
          shape: shape,
        );
      case ButtonVariant.text:
        return TextButton.styleFrom(
          foregroundColor: const Color(0xFF4F46E5),
          shape: shape,
        );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../molecules/password_criteria_badge.dart';
import '../molecules/password_strength_indicator.dart';

class RegisterFormOrganism extends StatefulWidget {
  final bool isLoading;
  final Future<void> Function({
    required String email,
    required String password,
  }) onRegister;
  final bool isDark;

  const RegisterFormOrganism({
    super.key,
    required this.isLoading,
    required this.onRegister,
    required this.isDark,
  });

  @override
  State<RegisterFormOrganism> createState() => _RegisterFormOrganismState();
}

class _RegisterFormOrganismState extends State<RegisterFormOrganism> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onRegister(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const brandPrimary = Color(0xFF4F46E5);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Correo Institucional',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: _inputDecoration(
              hintText: 'ejemplo@universidad.edu.co',
              prefixIcon: Icons.mail_outline_rounded,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa tu correo institucional';
              }
              if (!value.contains('@')) {
                return 'Ingresa un formato de correo válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),
          Text(
            'Crear Contraseña',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: _inputDecoration(
              hintText: 'Mínimo 6 caracteres',
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: widget.isDark ? Colors.white54 : const Color(0xFF94A3B8),
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            onChanged: (_) => setState(() {}),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Crea una contraseña';
              }
              if (value.length < 6) {
                return 'Debe tener al menos 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          PasswordStrengthIndicator(
            password: _passwordController.text,
            isDark: widget.isDark,
          ),
          const SizedBox(height: 14),
          Text(
            'Confirmar Contraseña',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.isDark ? Colors.white70 : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: widget.isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: _inputDecoration(
              hintText: 'Repite tu contraseña',
              prefixIcon: Icons.lock_reset_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: widget.isDark ? Colors.white54 : const Color(0xFF94A3B8),
                ),
                onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword),
              ),
            ),
            onChanged: (_) => setState(() {}),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirma tu contraseña';
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              PasswordCriteriaBadge(
                label: 'Mínimo 6 caracteres',
                isValid: _passwordController.text.length >= 6,
                isDark: widget.isDark,
              ),
              const SizedBox(width: 8),
              PasswordCriteriaBadge(
                label: 'Coinciden',
                isValid: _passwordController.text.isNotEmpty &&
                    _passwordController.text == _confirmPasswordController.text,
                isDark: widget.isDark,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: brandPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      'Crear Cuenta de Practicante',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    const brandPrimary = Color(0xFF4F46E5);

    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        color: widget.isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
      ),
      prefixIcon: Icon(
        prefixIcon,
        size: 20,
        color: widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: widget.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: widget.isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: brandPrimary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
      ),
    );
  }
}

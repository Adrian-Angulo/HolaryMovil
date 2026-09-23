import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';
import '../providers/dependency_injection.dart';
import '../providers/perfil_provider.dart';
import '../providers/registro_provider.dart';
import 'home_navigation_screen.dart';
import 'registro_perfil_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();

  // Login Controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _loginObscurePassword = true;
  bool _rememberSession = true;

  // Focus Nodes for smooth keyboard navigation
  final _loginEmailFocus = FocusNode();
  final _loginPasswordFocus = FocusNode();

  // Register Controllers
  final _registerNombreController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  bool _registerObscurePassword = true;
  bool _registerObscureConfirm = true;

  final _registerNombreFocus = FocusNode();
  final _registerEmailFocus = FocusNode();
  final _registerPasswordFocus = FocusNode();
  final _registerConfirmFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging ||
          _tabController.index != _selectedTabIndex) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });

    // Rebuild on register password change for real-time validation badges
    _registerPasswordController.addListener(() {
      if (mounted && _selectedTabIndex == 1) setState(() {});
    });
    _registerConfirmPasswordController.addListener(() {
      if (mounted && _selectedTabIndex == 1) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _loginEmailFocus.dispose();
    _loginPasswordFocus.dispose();

    _registerNombreController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    _registerNombreFocus.dispose();
    _registerEmailFocus.dispose();
    _registerPasswordFocus.dispose();
    _registerConfirmFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final success = await authNotifier.login(
      email: _loginEmailController.text.trim(),
      password: _loginPasswordController.text,
    );

    if (success && mounted) {
      _showSuccessFeedback('¡Bienvenido! Sesión iniciada con éxito');
      await ref.read(perfilNotifierProvider.notifier).loadPerfil();
      await ref.read(registrosNotifierProvider.notifier).loadRegistros();

      if (!mounted) return;

      final storage = ref.read(sessionStorageProvider);
      final bool estaCompletado = storage.isPerfilCompletado();
      final destino = estaCompletado
          ? const HomeNavigationScreen()
          : const RegistroPerfilScreen();

      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => destino));
    }
  }

  Future<void> _handleRegister() async {
    if (!_registerFormKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final authNotifier = ref.read(authNotifierProvider.notifier);
    final success = await authNotifier.register(
      nombre: _registerNombreController.text.trim(),
      email: _registerEmailController.text.trim(),
      password: _registerPasswordController.text,
    );

    if (success && mounted) {
      _showSuccessFeedback('¡Cuenta de practicante creada con éxito!');
      await ref.read(perfilNotifierProvider.notifier).loadPerfil();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RegistroPerfilScreen()),
      );
    }
  }

  void _showSuccessFeedback(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showForgotPasswordModal() {
    final emailForgotController = TextEditingController(
      text: _loginEmailController.text.trim(),
    );
    final tokenController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool obscureNew = true;
    bool obscureConfirm = true;
    int currentStep = 0; // 0 = pedir correo, 1 = ingresar token y nueva clave
    bool isProcessing = false;
    String? modalError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final isDark = Theme.of(modalContext).brightness == Brightness.dark;
            const Color brandPrimary = Color(0xFF4F46E5);
            const Color brandSecondary = Color(0xFF6366F1);

            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 30,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Sheet Handle
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

                    // Title Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: brandPrimary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.lock_reset_rounded,
                            color: brandPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Restablecer Contraseña',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0F172A),
                                ),
                              ),
                              Text(
                                currentStep == 0
                                    ? 'Paso 1: Solicitud de código de seguridad'
                                    : 'Paso 2: Configurar nueva contraseña',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (modalError != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFEF4444)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFFEF4444),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                modalError!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFEF4444),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),

                    if (currentStep == 0) ...[
                      // STEP 0: Ingrese Correo
                      Text(
                        'Ingresa tu correo institucional registrado para generar el código de recuperación:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF475569),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: emailForgotController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                        decoration: _inputDecoration(
                          hintText: 'ejemplo@universidad.edu.pe',
                          prefixIcon: Icons.alternate_email_rounded,
                          isDark: isDark,
                          brandPrimary: brandPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isProcessing
                              ? null
                              : () async {
                                  final email = emailForgotController.text
                                      .trim();
                                  if (email.isEmpty || !email.contains('@')) {
                                    setModalState(() {
                                      modalError = 'Por favor ingresa un correo electrónico válido.';
                                    });
                                    return;
                                  }

                                  setModalState(() {
                                    isProcessing = true;
                                    modalError = null;
                                  });

                                  final authNotifier = ref.read(
                                    authNotifierProvider.notifier,
                                  );
                                  final result = await authNotifier
                                      .requestPasswordReset(email);

                                  setModalState(() {
                                    isProcessing = false;
                                  });

                                  if (result != null) {
                                    final devToken =
                                        result['data']?['devResetToken']
                                            as String?;
                                    if (devToken != null) {
                                      tokenController.text = devToken;
                                    }
                                    setModalState(() {
                                      currentStep = 1;
                                      modalError = null;
                                    });
                                  } else {
                                    final currentErr = ref
                                        .read(authNotifierProvider)
                                        .errorMessage;
                                    setModalState(() {
                                      modalError = currentErr ?? 'No se pudo procesar la solicitud de recuperación.';
                                    });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Continuar con Recuperación',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ] else ...[
                      // STEP 1: Ingrese Token y Nueva Clave
                      Text(
                        'Ingresa el código o token de recuperación y define tu nueva contraseña:',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFFCBD5E1)
                              : const Color(0xFF475569),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Token Field
                      TextField(
                        controller: tokenController,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                        decoration: _inputDecoration(
                          hintText: 'Código o Token de Recuperación',
                          prefixIcon: Icons.vpn_key_rounded,
                          isDark: isDark,
                          brandPrimary: brandPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Nueva Clave
                      TextField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                        decoration: _inputDecoration(
                          hintText: 'Nueva Contraseña (mínimo 6 caracteres)',
                          prefixIcon: Icons.lock_outline_rounded,
                          isDark: isDark,
                          brandPrimary: brandPrimary,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                              color: isDark
                                  ? Colors.white54
                                  : const Color(0xFF94A3B8),
                            ),
                            onPressed: () {
                              setModalState(() {
                                obscureNew = !obscureNew;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Confirmar Clave
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                        decoration: _inputDecoration(
                          hintText: 'Confirmar Nueva Contraseña',
                          prefixIcon: Icons.lock_reset_rounded,
                          isDark: isDark,
                          brandPrimary: brandPrimary,
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                              color: isDark
                                  ? Colors.white54
                                  : const Color(0xFF94A3B8),
                            ),
                            onPressed: () {
                              setModalState(() {
                                obscureConfirm = !obscureConfirm;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Criteria Badges
                      Row(
                        children: [
                          _buildCriteriaBadge(
                            label: '6+ caracteres',
                            isValid: newPasswordController.text.length >= 6,
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                          _buildCriteriaBadge(
                            label: 'Coinciden',
                            isValid:
                                newPasswordController.text.isNotEmpty &&
                                newPasswordController.text ==
                                    confirmPasswordController.text,
                            isDark: isDark,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isProcessing
                              ? null
                              : () async {
                                  final token = tokenController.text.trim();
                                  final newPass = newPasswordController.text;
                                  final confirmPass =
                                      confirmPasswordController.text;

                                  if (token.isEmpty) {
                                    setModalState(() {
                                      modalError =
                                          'Ingresa el token de recuperación.';
                                    });
                                    return;
                                  }
                                  if (newPass.length < 6) {
                                    setModalState(() {
                                      modalError = 'La contraseña debe tener al menos 6 caracteres.';
                                    });
                                    return;
                                  }
                                  if (newPass != confirmPass) {
                                    setModalState(() {
                                      modalError =
                                          'Las contraseñas no coinciden.';
                                    });
                                    return;
                                  }

                                  setModalState(() {
                                    isProcessing = true;
                                    modalError = null;
                                  });

                                  final authNotifier = ref.read(
                                    authNotifierProvider.notifier,
                                  );
                                  final success = await authNotifier
                                      .resetPassword(
                                        token: token,
                                        newPassword: newPass,
                                      );

                                  setModalState(() {
                                    isProcessing = false;
                                  });

                                  if (success) {
                                    if (modalContext.mounted) {
                                      Navigator.pop(modalContext);
                                    }
                                    _loginEmailController.text =
                                        emailForgotController.text.trim();
                                    _loginPasswordController.text = newPass;
                                    _showSuccessFeedback(
                                      '¡Contraseña actualizada exitosamente! Ya puedes iniciar sesión.',
                                    );
                                  } else {
                                    final currentErr = ref
                                        .read(authNotifierProvider)
                                        .errorMessage;
                                    setModalState(() {
                                      modalError =
                                          currentErr ??
                                          'Token inválido o expirado.';
                                    });
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: brandPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isProcessing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Guardar Nueva Contraseña',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            currentStep = 0;
                            modalError = null;
                          });
                        },
                        child: Text(
                          '← Volver a solicitar código',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: brandSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen to error messages and show a floating snackbar
    ref.listen(authNotifierProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    next.errorMessage!,
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () =>
                  ref.read(authNotifierProvider.notifier).clearError(),
            ),
          ),
        );
      }
    });

    final Color bgGradientStart = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final Color bgGradientEnd = isDark
        ? const Color(0xFF020617)
        : const Color(0xFFEEF2FF);
    final Color cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    const Color brandPrimary = Color(0xFF4F46E5);
    const Color brandSecondary = Color(0xFF6366F1);

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [bgGradientStart, bgGradientEnd],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Top Bar / Quick Actions
                  _buildTopBar(isDark),

                  const SizedBox(height: 16),

                  // 2. Hero Branding & Welcome Header
                  _buildHeroHeader(isDark, brandPrimary),

                  const SizedBox(height: 24),

                  // 3. Segmented Tab Switcher (Pill Style)
                  _buildSegmentedTabSwitcher(isDark, brandPrimary),

                  const SizedBox(height: 20),

                  // 4. Main Interactive Form Card
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.3)
                                : const Color(0xFF4F46E5)
                                      .withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      padding: const EdgeInsets.all(22),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: _selectedTabIndex == 0
                            ? _buildLoginForm(
                                isDark: isDark,
                                brandPrimary: brandPrimary,
                                brandSecondary: brandSecondary,
                                isLoading: authState.isLoading,
                              )
                            : _buildRegisterForm(
                                isDark: isDark,
                                brandPrimary: brandPrimary,
                                brandSecondary: brandSecondary,
                                isLoading: authState.isLoading,
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5. Trust & Usability Footer
                  _buildTrustFooter(isDark),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- SUB-WIDGETS ---

  Widget _buildTopBar(bool isDark) {
    return FadeInDown(
      duration: const Duration(milliseconds: 350),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFC7D2FE),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Portal Practicante',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFF93C5FD)
                      : const Color(0xFF4338CA),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader(bool isDark, Color brandPrimary) {
    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      child: Column(
        children: [
          // App Logo Icon
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Image.asset('assets/logo.png', fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Text(
            'Horaly',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: Text(
              _selectedTabIndex == 0
                  ? 'Gestiona y acredita tus horas de prácticas pre-profesionales'
                  : 'Regístrate para comenzar el cómputo de tus jornadas',
              key: ValueKey<int>(_selectedTabIndex),
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabSwitcher(bool isDark, Color brandPrimary) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 0
                      ? (isDark ? const Color(0xFF334155) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedTabIndex == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.login_rounded,
                      size: 16,
                      color: _selectedTabIndex == 0
                          ? (isDark ? Colors.white : brandPrimary)
                          : (isDark ? Colors.white54 : const Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Iniciar Sesión',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: _selectedTabIndex == 0
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: _selectedTabIndex == 0
                            ? (isDark ? Colors.white : brandPrimary)
                            : (isDark
                                  ? Colors.white54
                                  : const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: _selectedTabIndex == 1
                      ? (isDark ? const Color(0xFF334155) : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _selectedTabIndex == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 16,
                      color: _selectedTabIndex == 1
                          ? (isDark ? Colors.white : brandPrimary)
                          : (isDark ? Colors.white54 : const Color(0xFF64748B)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Crear Cuenta',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: _selectedTabIndex == 1
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: _selectedTabIndex == 1
                            ? (isDark ? Colors.white : brandPrimary)
                            : (isDark
                                  ? Colors.white54
                                  : const Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIN FORM ---

  Widget _buildLoginForm({
    required bool isDark,
    required Color brandPrimary,
    required Color brandSecondary,
    required bool isLoading,
  }) {
    return Form(
      key: _loginFormKey,
      child: Column(
        key: const ValueKey('login_form'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Correo Field
          Text(
            'Correo Institucional o Registrado',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _loginEmailController,
            focusNode: _loginEmailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email, AutofillHints.username],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: _inputDecoration(
              hintText: 'ejemplo@universidad.edu.pe',
              prefixIcon: Icons.alternate_email_rounded,
              isDark: isDark,
              brandPrimary: brandPrimary,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Por favor ingresa tu correo';
              }
              if (!val.contains('@') || !val.contains('.')) {
                return 'Ingresa un correo electrónico válido';
              }
              return null;
            },
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_loginPasswordFocus),
          ),

          const SizedBox(height: 16),

          // Contraseña Field Header with Forgot Password action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Contraseña',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFFCBD5E1)
                      : const Color(0xFF334155),
                ),
              ),
              GestureDetector(
                onTap: _showForgotPasswordModal,
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: brandPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _loginPasswordController,
            focusNode: _loginPasswordFocus,
            obscureText: _loginObscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: _inputDecoration(
              hintText: 'Tu contraseña',
              prefixIcon: Icons.lock_outline_rounded,
              isDark: isDark,
              brandPrimary: brandPrimary,
              suffixIcon: IconButton(
                icon: Icon(
                  _loginObscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                ),
                onPressed: () {
                  setState(() {
                    _loginObscurePassword = !_loginObscurePassword;
                  });
                },
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Ingresa tu contraseña';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleLogin(),
          ),

          const SizedBox(height: 12),

          // Remember session toggle
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _rememberSession,
                  activeColor: brandPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _rememberSession = val ?? true;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _rememberSession = !_rememberSession;
                  });
                },
                child: Text(
                  'Recordar sesión en este dispositivo',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Primary Submit CTA Button
          _buildSubmitButton(
            label: 'Ingresar al Portal',
            icon: Icons.arrow_forward_rounded,
            isLoading: isLoading,
            brandPrimary: brandPrimary,
            brandSecondary: brandSecondary,
            onPressed: _handleLogin,
          ),

          const SizedBox(height: 16),

          // Switch to Register prompt
          Center(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(1),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                  children: [
                    const TextSpan(text: '¿No tienes una cuenta? '),
                    TextSpan(
                      text: 'Regístrate aquí',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        color: brandPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- REGISTER FORM ---

  Widget _buildRegisterForm({
    required bool isDark,
    required Color brandPrimary,
    required Color brandSecondary,
    required bool isLoading,
  }) {
    final passwordText = _registerPasswordController.text;
    final confirmText = _registerConfirmPasswordController.text;

    final hasMinLength = passwordText.length >= 6;
    final passwordsMatch =
        passwordText.isNotEmpty && passwordText == confirmText;

    return Form(
      key: _registerFormKey,
      child: Column(
        key: const ValueKey('register_form'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nombres Completos
          Text(
            'Nombres y Apellidos Completos',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _registerNombreController,
            focusNode: _registerNombreFocus,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: _inputDecoration(
              hintText: 'Ej. Juan Carlos Pérez Quispe',
              prefixIcon: Icons.badge_outlined,
              isDark: isDark,
              brandPrimary: brandPrimary,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Ingresa tus nombres completos';
              }
              if (val.trim().length < 3) {
                return 'El nombre debe tener al menos 3 caracteres';
              }
              return null;
            },
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_registerEmailFocus),
          ),

          const SizedBox(height: 14),

          // Correo Institucional
          Text(
            'Correo Institucional o Personal',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _registerEmailController,
            focusNode: _registerEmailFocus,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: _inputDecoration(
              hintText: 'ejemplo@universidad.edu.pe',
              prefixIcon: Icons.mail_outline_rounded,
              isDark: isDark,
              brandPrimary: brandPrimary,
            ),
            validator: (val) {
              if (val == null || val.trim().isEmpty) {
                return 'Ingresa un correo electrónico';
              }
              if (!val.contains('@') || !val.contains('.')) {
                return 'Ingresa un formato de correo válido';
              }
              return null;
            },
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_registerPasswordFocus),
          ),

          const SizedBox(height: 14),

          // Contraseña
          Text(
            'Contraseña (Mínimo 6 caracteres)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _registerPasswordController,
            focusNode: _registerPasswordFocus,
            obscureText: _registerObscurePassword,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.newPassword],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: _inputDecoration(
              hintText: 'Crea tu contraseña segura',
              prefixIcon: Icons.lock_outline_rounded,
              isDark: isDark,
              brandPrimary: brandPrimary,
              suffixIcon: IconButton(
                icon: Icon(
                  _registerObscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                ),
                onPressed: () {
                  setState(() {
                    _registerObscurePassword = !_registerObscurePassword;
                  });
                },
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Ingresa una contraseña';
              }
              if (val.length < 6) {
                return 'La contraseña debe tener mínimo 6 caracteres';
              }
              return null;
            },
            onFieldSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_registerConfirmFocus),
          ),

          const SizedBox(height: 14),

          // Confirmar Contraseña
          Text(
            'Confirmar Contraseña',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _registerConfirmPasswordController,
            focusNode: _registerConfirmFocus,
            obscureText: _registerObscureConfirm,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.newPassword],
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            decoration: _inputDecoration(
              hintText: 'Repite tu contraseña',
              prefixIcon: Icons.lock_reset_rounded,
              isDark: isDark,
              brandPrimary: brandPrimary,
              suffixIcon: IconButton(
                icon: Icon(
                  _registerObscureConfirm
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                ),
                onPressed: () {
                  setState(() {
                    _registerObscureConfirm = !_registerObscureConfirm;
                  });
                },
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Confirma tu contraseña';
              }
              if (val != _registerPasswordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleRegister(),
          ),

          const SizedBox(height: 12),

          // Live Password Criteria feedback badges
          Row(
            children: [
              _buildCriteriaBadge(
                label: '6+ caracteres',
                isValid: hasMinLength,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildCriteriaBadge(
                label: 'Coinciden',
                isValid: passwordsMatch,
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Primary Submit CTA Button
          _buildSubmitButton(
            label: 'Crear Cuenta de Practicante',
            icon: Icons.check_rounded,
            isLoading: isLoading,
            brandPrimary: brandPrimary,
            brandSecondary: brandSecondary,
            onPressed: _handleRegister,
          ),

          const SizedBox(height: 16),

          // Switch to Login prompt
          Center(
            child: GestureDetector(
              onTap: () => _tabController.animateTo(0),
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                  children: [
                    const TextSpan(text: '¿Ya tienes una cuenta? '),
                    TextSpan(
                      text: 'Inicia sesión',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        color: brandPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- REUSABLE UI HELPERS ---

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    required bool isDark,
    required Color brandPrimary,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
      ),
      filled: true,
      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      prefixIcon: Icon(
        prefixIcon,
        size: 19,
        color: isDark ? const Color(0xFF818CF8) : const Color(0xFF6366F1),
      ),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: brandPrimary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.8),
      ),
    );
  }

  Widget _buildCriteriaBadge({
    required String label,
    required bool isValid,
    required bool isDark,
  }) {
    final color = isValid
        ? const Color(0xFF10B981)
        : (isDark ? Colors.white38 : Colors.grey.shade400);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: isValid
            ? const Color(0xFF10B981).withValues(alpha: 0.12)
            : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid
              ? const Color(0xFF10B981).withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton({
    required String label,
    required IconData icon,
    required bool isLoading,
    required Color brandPrimary,
    required Color brandSecondary,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [brandPrimary, brandSecondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: brandPrimary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(icon, size: 18, color: Colors.white),
                ],
              ),
      ),
    );
  }

  Widget _buildTrustFooter(bool isDark) {
    return FadeInUp(
      duration: const Duration(milliseconds: 450),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_rounded,
              size: 13,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 5),
            Text(
              'Conexión segura SSL/TLS de 256 bits',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

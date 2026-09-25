import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:practi_horas_app/core/constants/app_constants.dart';
import 'package:practi_horas_app/core/di/dependency_injection.dart';
import 'package:practi_horas_app/core/shared_atomic/atoms/custom_card.dart';
import 'package:practi_horas_app/core/shared_atomic/molecules/menu_action_tile.dart';
import 'package:practi_horas_app/core/utils/csv_exporter.dart';
import 'package:practi_horas_app/core/utils/date_formatters.dart';
import 'package:practi_horas_app/core/utils/pdf_exporter.dart';
import 'package:practi_horas_app/features/auth/presentation/screens/auth_screen.dart';
import 'package:practi_horas_app/features/registros/presentation/providers/registro_provider.dart';
import 'package:practi_horas_app/features/perfil/domain/entities/horario_dia.dart';
import 'package:practi_horas_app/features/perfil/domain/entities/perfil.dart';
import 'package:practi_horas_app/features/perfil/presentation/providers/perfil_provider.dart';
import 'package:practi_horas_app/features/perfil/presentation/providers/theme_provider.dart';
import 'package:practi_horas_app/features/perfil/presentation/widgets/molecules/horario_dia_item.dart';
import 'package:practi_horas_app/features/perfil/presentation/widgets/organisms/edit_horario_modal.dart';
import 'package:practi_horas_app/features/perfil/presentation/widgets/organisms/edit_metas_modal.dart';
import 'package:practi_horas_app/features/perfil/presentation/widgets/organisms/edit_periodo_modal.dart';
import 'package:practi_horas_app/features/perfil/presentation/widgets/organisms/perfil_header_organism.dart';
import 'package:practi_horas_app/features/perfil/presentation/widgets/organisms/theme_selector_modal.dart';

class PerfilConfigScreen extends ConsumerStatefulWidget {
  const PerfilConfigScreen({super.key});

  @override
  ConsumerState<PerfilConfigScreen> createState() => _PerfilConfigScreenState();
}

class _PerfilConfigScreenState extends ConsumerState<PerfilConfigScreen> {
  void _openEditMetas(Perfil perfil) {
    EditMetasModal.show(
      context: context,
      perfil: perfil,
      onSave: ({
        required double metaHoras,
        required double horasMinimasSemanales,
        required double horasInicialesPrevias,
      }) async {
        await ref
            .read(perfilNotifierProvider.notifier)
            .updateConfiguracionGeneral(
              nombre: perfil.nombre,
              metaHoras: metaHoras,
              horasInicialesPrevias: horasInicialesPrevias,
              horasMinimasSemanales: horasMinimasSemanales,
            );
        _showSuccessSnackBar('Metas y horas actualizadas con éxito');
      },
    );
  }

  void _openEditPeriodo(Perfil perfil) {
    EditPeriodoModal.show(
      context: context,
      perfil: perfil,
      onSave: ({
        required DateTime? fechaInicio,
        required DateTime? fechaFin,
      }) async {
        await ref
            .read(perfilNotifierProvider.notifier)
            .updateConfiguracionGeneral(
              nombre: perfil.nombre,
              metaHoras: perfil.metaHorasTotal,
              horasInicialesPrevias: perfil.horasInicialesPrevias,
              fechaInicio: fechaInicio,
              fechaFin: fechaFin,
            );
        _showSuccessSnackBar('Período de prácticas actualizado con éxito');
      },
    );
  }

  void _openEditHorario(String diaKey, HorarioDia horario) {
    EditHorarioModal.show(
      context: context,
      diaKey: diaKey,
      horario: horario,
      onSave: (updated) async {
        await ref
            .read(perfilNotifierProvider.notifier)
            .updateHorarioDia(diaKey, updated);
        _showSuccessSnackBar(
          'Horario de ${DateFormatters.getDiaNombre(diaKey)} actualizado',
        );
      },
    );
  }

  void _openThemeSelector(ThemeMode currentTheme) {
    ThemeSelectorModal.show(
      context: context,
      currentTheme: currentTheme,
      onSelectTheme: (mode) {
        ref.read(themeNotifierProvider.notifier).setThemeMode(mode);
        _showSuccessSnackBar('Tema actualizado correctamente');
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
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
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _exportarReportesDesdePerfil() async {
    final todosLosRegistros = ref.read(registrosNotifierProvider).value ?? [];
    final perfil = ref.read(perfilNotifierProvider).value ??
        Perfil.defaultPerfil().copyWith(
          nombre: ref.read(sessionStorageProvider).getUserName() ?? 'Practicante',
        );
    final userEmail = ref.read(sessionStorageProvider).getUserEmail();
    final horasPrevias = perfil.horasInicialesPrevias;

    if (todosLosRegistros.isEmpty && horasPrevias <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'No hay registros ni horas previas para exportar.',
          ),
          backgroundColor: Colors.amber.shade800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.file_download_rounded,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exportar Reporte Oficial',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Elige el formato para presentar o archivar',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Opción PDF con firmas
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await PdfExporter.exportarYCompartirPdf(
                      registros: todosLosRegistros,
                      perfil: perfil,
                      email: userEmail,
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                  label: const Text('Ficha Oficial en PDF (Con Firmas)'),
                ),
              ),
              const SizedBox(height: 10),
              // Opción CSV
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await CsvExporter.exportarYCompartirCsv(
                      registros: todosLosRegistros,
                      horasInicialesPrevias: horasPrevias,
                      nombrePracticante: perfil.nombre,
                    );
                  },
                  icon: const Icon(Icons.table_chart_rounded, size: 18),
                  label: const Text('Reporte CSV / Excel (Datos crudos)'),
                ),
              ),
              const SizedBox(height: 10),
              // Copiar Portapapeles
              SizedBox(
                width: double.infinity,
                height: 40,
                child: TextButton.icon(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await CsvExporter.copiarCsvAlPortapapeles(
                      registros: todosLosRegistros,
                      horasInicialesPrevias: horasPrevias,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📋 CSV copiado al portapapeles'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copiar formato CSV'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmarCerrarSesion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text(
          '¿Estás seguro de que deseas salir de tu cuenta en este dispositivo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(logoutUseCaseProvider).call();
      ref.invalidate(perfilNotifierProvider);
      ref.invalidate(registrosNotifierProvider);

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfilAsync = ref.watch(perfilNotifierProvider);
    final userEmail = ref.read(sessionStorageProvider).getUserEmail() ?? '';
    final currentTheme = ref.watch(themeNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color bgGradientStart = isDark
        ? const Color(0xFF0F172A)
        : const Color(0xFFF8FAFC);
    final Color bgGradientEnd = isDark
        ? const Color(0xFF020617)
        : const Color(0xFFEEF2FF);

    final storage = ref.read(sessionStorageProvider);
    final fallbackNombre = storage.getUserName() ?? 'Practicante';
    final perfil = perfilAsync.value ??
        Perfil.defaultPerfil().copyWith(
          nombre: fallbackNombre,
          perfilCompletado: storage.isPerfilCompletado(),
        );

    if (perfilAsync.isLoading && perfilAsync.value == null) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [bgGradientStart, bgGradientEnd],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [bgGradientStart, bgGradientEnd],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (perfilAsync.hasError) ...[
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          color: Color(0xFFF59E0B),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Modo sin conexión. Mostrando datos guardados localmente.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFFDE68A)
                                  : const Color(0xFFB45309),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                  // 1. Cabecera del Perfil
                  PerfilHeaderOrganism(
                    perfil: perfil,
                    email: userEmail,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 24),

                  // 2. Sección: Metas y Convenio
                  Text(
                    'Parámetros del Convenio',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        MenuActionTile(
                          icon: Icons.flag_rounded,
                          iconColor: const Color(0xFF4F46E5),
                          title: 'Meta de Horas y Convalidación',
                          subtitle:
                              '${perfil.metaHorasTotal.toStringAsFixed(0)}h meta • ${perfil.horasInicialesPrevias.toStringAsFixed(1)}h cursadas',
                          onTap: () => _openEditMetas(perfil),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        MenuActionTile(
                          icon: Icons.calendar_month_rounded,
                          iconColor: const Color(0xFF0284C7),
                          title: 'Período de Prácticas',
                          subtitle: perfil.fechaInicio != null &&
                                  perfil.fechaFin != null
                              ? '${DateFormatters.fechaCorta(perfil.fechaInicio!)} — ${DateFormatters.fechaCorta(perfil.fechaFin!)}'
                              : 'Configurar fechas de inicio y término',
                          onTap: () => _openEditPeriodo(perfil),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 3. Sección: Horario Semanal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Horario Semanal Programado',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        '${perfil.horasMinimasSemanales.toStringAsFixed(0)}h / sem mín',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  CustomCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: AppConstants.diasSemanaKeys.map((diaKey) {
                        final horario = perfil.horarioSemanal[diaKey] ??
                            HorarioDia.porDefecto(diaKey);
                        return HorarioDiaItem(
                          diaKey: diaKey,
                          horario: horario,
                          onTap: () => _openEditHorario(diaKey, horario),
                          isDark: isDark,
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 4. Sección: Preferencias y Sesión
                  Text(
                    'Preferencias y Cuenta',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        MenuActionTile(
                          icon: currentTheme == ThemeMode.dark
                              ? Icons.dark_mode_rounded
                              : (currentTheme == ThemeMode.light
                                  ? Icons.light_mode_rounded
                                  : Icons.brightness_auto_rounded),
                          iconColor: const Color(0xFFF59E0B),
                          title: 'Tema de la Aplicación',
                          subtitle: currentTheme == ThemeMode.dark
                              ? 'Modo Oscuro activado'
                              : (currentTheme == ThemeMode.light
                                  ? 'Modo Claro activado'
                                  : 'Automático (Sigue al sistema)'),
                          onTap: () => _openThemeSelector(currentTheme),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        MenuActionTile(
                          icon: Icons.file_download_rounded,
                          iconColor: const Color(0xFF059669),
                          title: 'Exportar Reportes (PDF / Excel)',
                          subtitle:
                              'Generar Ficha Oficial con firmas o archivo CSV',
                          onTap: _exportarReportesDesdePerfil,
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        MenuActionTile(
                          icon: Icons.logout_rounded,
                          iconColor: const Color(0xFFEF4444),
                          title: 'Cerrar Sesión',
                          subtitle: 'Salir de la cuenta de practicante',
                          onTap: _confirmarCerrarSesion,
                          isDark: isDark,
                          isDestructive: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
      indent: 52,
      endIndent: 16,
    );
  }
}

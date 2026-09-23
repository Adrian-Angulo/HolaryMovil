import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/csv_exporter.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/utils/time_calculator.dart';
import '../../domain/entities/horario_dia.dart';
import '../../domain/entities/perfil.dart';
import '../providers/auth_provider.dart';
import '../providers/dependency_injection.dart';
import '../providers/perfil_provider.dart';
import '../providers/registro_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/common/custom_card.dart';
import 'auth_screen.dart';

class PerfilConfigScreen extends ConsumerStatefulWidget {
  const PerfilConfigScreen({super.key});

  @override
  ConsumerState<PerfilConfigScreen> createState() => _PerfilConfigScreenState();
}

class _PerfilConfigScreenState extends ConsumerState<PerfilConfigScreen> {
  Future<void> _editarMetaYHoras(Perfil perfil) async {
    final metaController = TextEditingController(
      text: perfil.metaHorasTotal.toStringAsFixed(0),
    );
    final minimasController = TextEditingController(
      text: perfil.horasMinimasSemanales.toStringAsFixed(0),
    );
    final previasController = TextEditingController(
      text: perfil.horasInicialesPrevias.toStringAsFixed(1),
    );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            left: 24,
            right: 24,
            top: 20,
          ),
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
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: Color(0xFF4F46E5),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meta y Cómputo de Horas',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Ajusta los objetivos de tu convenio de prácticas',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
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
              const SizedBox(height: 20),

              // Meta total
              Text(
                'Meta Total de Horas',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: metaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Ej. 360',
                  suffixText: 'horas',
                  prefixIcon: const Icon(Icons.stars_rounded),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Minimo de semana
              Text(
                'Mínimo Requerido por Semana',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: minimasController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Ej. 30',
                  suffixText: 'hrs / sem',
                  prefixIcon: const Icon(Icons.date_range_rounded),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Horas ya cursadas (horas iniciales previas)
              Text(
                'Horas Ya Cursadas (Iniciales Previas)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Horas convalidadas o acumuladas antes de comenzar en la app.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: isDark ? Colors.white54 : Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: previasController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: 'Ej. 0 o 45.5',
                  suffixText: 'horas',
                  prefixIcon: const Icon(Icons.history_toggle_off_rounded),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final meta =
                        double.tryParse(metaController.text.trim()) ??
                        perfil.metaHorasTotal;
                    final minimas =
                        double.tryParse(minimasController.text.trim()) ??
                        perfil.horasMinimasSemanales;
                    final previas =
                        double.tryParse(previasController.text.trim()) ??
                        perfil.horasInicialesPrevias;

                    await ref
                        .read(perfilNotifierProvider.notifier)
                        .updateConfiguracionGeneral(
                          nombre: perfil.nombre,
                          metaHoras: meta,
                          horasInicialesPrevias: previas,
                          horasMinimasSemanales: minimas,
                          fechaInicio: perfil.fechaInicio,
                          fechaFin: perfil.fechaFin,
                        );

                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      _showSuccessSnackBar(
                        'Metas y horas actualizadas con éxito',
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Guardar Cambios',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editarFechasPeriodo(Perfil perfil) async {
    DateTime? fechaInicio = perfil.fechaInicio ?? DateTime.now();
    DateTime? fechaFin =
        perfil.fechaFin ?? fechaInicio.add(const Duration(days: 90));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 70,
                left: 24,
                right: 24,
                top: 20,
              ),
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
                          color: const Color(0xFF0284C7)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          color: Color(0xFF0284C7),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Período de Prácticas',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Fechas de inicio y término del convenio',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
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
                  const SizedBox(height: 20),

                  // Fecha Inicio
                  Text(
                    'Fecha de Inicio',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: fechaInicio ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2035),
                        locale: const Locale('es', 'ES'),
                      );
                      if (picked != null) {
                        setModalState(() {
                          fechaInicio = picked;
                          if (fechaFin != null && fechaFin!.isBefore(picked)) {
                            fechaFin = picked.add(const Duration(days: 90));
                          }
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            fechaInicio != null
                                ? DateFormatters.fechaCorta(fechaInicio!)
                                : 'Seleccionar fecha',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(Icons.calendar_today_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Fecha Fin
                  Text(
                    'Fecha Estimada de Fin',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            fechaFin ??
                            (fechaInicio != null
                                ? fechaInicio!.add(const Duration(days: 90))
                                : DateTime.now()),
                        firstDate: fechaInicio ?? DateTime(2020),
                        lastDate: DateTime(2035),
                        locale: const Locale('es', 'ES'),
                      );
                      if (picked != null) {
                        setModalState(() => fechaFin = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF0F172A)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            fechaFin != null
                                ? DateFormatters.fechaCorta(fechaFin!)
                                : 'Seleccionar fecha',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Icon(Icons.event_available_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref
                            .read(perfilNotifierProvider.notifier)
                            .updateConfiguracionGeneral(
                              nombre: perfil.nombre,
                              metaHoras: perfil.metaHorasTotal,
                              horasInicialesPrevias:
                                  perfil.horasInicialesPrevias,
                              horasMinimasSemanales:
                                  perfil.horasMinimasSemanales,
                              fechaInicio: fechaInicio,
                              fechaFin: fechaFin,
                            );

                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          _showSuccessSnackBar(
                            'Período de prácticas actualizado con éxito',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Guardar Fechas',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _editarDatosPersonales(Perfil perfil) async {
    final nombreController = TextEditingController(text: perfil.nombre);
    final carreraController = TextEditingController(text: perfil.carrera);
    final semestreController = TextEditingController(text: perfil.semestre);

    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 70,
            left: 24,
            right: 24,
            top: 20,
          ),
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
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF10B981),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Datos del Practicante',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Información académica registrada',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
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
              const SizedBox(height: 20),

              // Nombre Completo
              Text(
                'Nombre Completo',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nombreController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Ej. Juan Carlos Pérez Quispe',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Carrera
              Text(
                'Carrera / Especialidad',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: carreraController,
                decoration: InputDecoration(
                  hintText: 'Ej. Ingeniería de Sistemas',
                  prefixIcon: const Icon(Icons.school_outlined),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Semestre
              Text(
                'Semestre Académico',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: semestreController,
                decoration: InputDecoration(
                  hintText: 'Ej. 2025-I',
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final newNombre = nombreController.text.trim();
                    if (newNombre.isEmpty) return;

                    final updated = perfil.copyWith(
                      nombre: newNombre,
                      carrera: carreraController.text.trim(),
                      semestre: semestreController.text.trim(),
                    );

                    await ref
                        .read(perfilNotifierProvider.notifier)
                        .updatePerfil(updated);
                    await ref
                        .read(sessionStorageProvider)
                        .saveUserName(newNombre);

                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      _showSuccessSnackBar('Datos personales actualizados');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Guardar Datos',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editarHorarioDia(String diaKey, HorarioDia horario) async {
    bool activo = horario.activo;
    String horaInicio = horario.horaInicio;
    String horaFin = horario.horaFin;
    String modalidad = horario.modalidad;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
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
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 70,
                left: 24,
                right: 24,
                top: 20,
              ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Configurar ${DateFormatters.getDiaNombre(diaKey)}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Switch.adaptive(
                        value: activo,
                        activeTrackColor: const Color(0xFF4F46E5),
                        onChanged: (val) {
                          setModalState(() => activo = val);
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  if (activo) ...[
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Hora Inicio',
                              style: TextStyle(fontSize: 12),
                            ),
                            subtitle: Text(
                              horaInicio,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () async {
                              final initial = TimeCalculator.parseTimeOfDay(
                                horaInicio,
                              );
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: initial,
                              );
                              if (picked != null) {
                                setModalState(() {
                                  horaInicio = TimeCalculator.formatTimeOfDay(
                                    picked,
                                  );
                                });
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Hora Fin',
                              style: TextStyle(fontSize: 12),
                            ),
                            subtitle: Text(
                              horaFin,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () async {
                              final initial = TimeCalculator.parseTimeOfDay(
                                horaFin,
                              );
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: initial,
                              );
                              if (picked != null) {
                                setModalState(() {
                                  horaFin = TimeCalculator.formatTimeOfDay(
                                    picked,
                                  );
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Modalidad Predeterminada',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: AppConstants.modalidades.map((mod) {
                        return ChoiceChip(
                          label: Text(mod),
                          selected: modalidad == mod,
                          selectedColor: const Color(0xFF4F46E5)
                              .withValues(alpha: 0.15),
                          onSelected: (_) =>
                              setModalState(() => modalidad = mod),
                        );
                      }).toList(),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Este día está marcado como no laboral / descanso.',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        final updated = horario.copyWith(
                          activo: activo,
                          horaInicio: horaInicio,
                          horaFin: horaFin,
                          refrigerioMinutos: 0,
                          modalidad: modalidad,
                        );
                        ref
                            .read(perfilNotifierProvider.notifier)
                            .updateHorarioDia(diaKey, updated);
                        Navigator.of(ctx).pop();
                        _showSuccessSnackBar(
                          'Horario de ${DateFormatters.getDiaNombre(diaKey)} actualizado',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        'Guardar Horario del Día',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarSelectorTema(BuildContext context, ThemeMode currentTheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
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
          padding: const EdgeInsets.only(
            bottom: 70,
            left: 24,
            right: 24,
            top: 20,
          ),
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
                      Icons.palette_rounded,
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
                          'Apariencia y Tema',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Elige el modo visual de la aplicación',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
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
              const SizedBox(height: 18),
              _buildThemeOptionTile(
                icon: Icons.light_mode_rounded,
                iconColor: const Color(0xFFF59E0B),
                title: 'Modo Claro',
                subtitle: 'Fondo blanco con alto contraste',
                isSelected: currentTheme == ThemeMode.light,
                isDark: isDark,
                onTap: () {
                  ref
                      .read(themeNotifierProvider.notifier)
                      .setThemeMode(ThemeMode.light);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 8),
              _buildThemeOptionTile(
                icon: Icons.dark_mode_rounded,
                iconColor: const Color(0xFF6366F1),
                title: 'Modo Oscuro',
                subtitle: 'Fondo oscuro para menor fatiga visual',
                isSelected: currentTheme == ThemeMode.dark,
                isDark: isDark,
                onTap: () {
                  ref
                      .read(themeNotifierProvider.notifier)
                      .setThemeMode(ThemeMode.dark);
                  Navigator.pop(ctx);
                },
              ),
              const SizedBox(height: 8),
              _buildThemeOptionTile(
                icon: Icons.brightness_auto_rounded,
                iconColor: const Color(0xFF10B981),
                title: 'Automático / Sistema',
                subtitle: 'Sincronizar con el tema configurado en tu celular',
                isSelected: currentTheme == ThemeMode.system,
                isDark: isDark,
                onTap: () {
                  ref
                      .read(themeNotifierProvider.notifier)
                      .setThemeMode(ThemeMode.system);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOptionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
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

  Future<void> _exportarCsvDesdePerfil() async {
    final todosLosRegistros = ref.read(registrosNotifierProvider).value ?? [];
    final perfil = ref.read(perfilNotifierProvider).value;
    final horasPrevias = perfil?.horasInicialesPrevias ?? 0.0;
    final nombre = perfil?.nombre ?? 'Practicante';

    if (todosLosRegistros.isEmpty && horasPrevias == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text('No hay registros de horas para exportar'),
            ],
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

    await CsvExporter.exportarYCompartirCsv(
      registros: todosLosRegistros,
      horasInicialesPrevias: horasPrevias,
      nombrePracticante: nombre,
    );
  }

  void _confirmarCerrarSesion() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '¿Cerrar Sesión?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Tendrás que volver a iniciar sesión con tus credenciales institucionales.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authNotifierProvider.notifier).logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              }
            },
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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgGradientStart, bgGradientEnd],
          ),
        ),
        child: SafeArea(
          child: perfilAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            ),
            error: (err, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      '$err',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(perfilNotifierProvider.notifier).loadPerfil(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
            data: (perfil) => SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Header Profile Card
                  _buildProfileHeader(perfil, userEmail, isDark),

                  const SizedBox(height: 20),

                  // 2. KPI Summary Cards (Clickable)
                  _buildKpiSummaryCards(perfil, isDark),

                  const SizedBox(height: 24),

                  // 3. Menus de Edición y Configuración
                  Text(
                    'Gestión de Prácticas',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Grupo 1: Metas, Fechas y Datos
                  CustomCard(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        _buildMenuTile(
                          icon: Icons.flag_rounded,
                          iconColor: const Color(0xFF4F46E5),
                          title: 'Meta y Cómputo de Horas',
                          subtitle:
                              '${perfil.metaHorasTotal.toInt()} hrs meta • ${perfil.horasMinimasSemanales.toInt()} hrs/sem • ${perfil.horasInicialesPrevias} previas',
                          onTap: () => _editarMetaYHoras(perfil),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildMenuTile(
                          icon: Icons.calendar_month_rounded,
                          iconColor: const Color(0xFF0284C7),
                          title: 'Período de Prácticas',
                          subtitle:
                              perfil.fechaInicio != null &&
                                  perfil.fechaFin != null
                              ? '${DateFormatters.fechaCorta(perfil.fechaInicio!)} — ${DateFormatters.fechaCorta(perfil.fechaFin!)}'
                              : 'Configurar fechas de inicio y término',
                          onTap: () => _editarFechasPeriodo(perfil),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildMenuTile(
                          icon: Icons.person_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: 'Datos del Practicante',
                          subtitle:
                              '${perfil.nombre} • ${perfil.carrera.isNotEmpty ? perfil.carrera : "Carrera"}',
                          onTap: () => _editarDatosPersonales(perfil),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Grupo 2: Horario Semanal Habitual
                  Text(
                    'Horario Semanal Habitual',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 10),

                  CustomCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: AppConstants.diasSemanaKeys.map((diaKey) {
                        final horario =
                            perfil.horarioSemanal[diaKey] ??
                            HorarioDia.porDefecto(diaKey);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: horario.activo
                                ? (isDark
                                      ? const Color(0xFF334155)
                                            .withValues(alpha: 0.4)
                                      : const Color(0xFFEEF2FF))
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            leading: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: horario.activo
                                    ? const Color(0xFF4F46E5)
                                    : (isDark
                                          ? Colors.white10
                                          : Colors.grey.shade200),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                DateFormatters.getDiaNombre(diaKey)
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: horario.activo
                                      ? Colors.white
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            title: Text(
                              DateFormatters.getDiaNombre(diaKey),
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            subtitle: Text(
                              horario.activo
                                  ? '${horario.horaInicio} - ${horario.horaFin} (${horario.modalidad})'
                                  : 'No laboral',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                color: horario.activo
                                    ? (isDark
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF4F46E5))
                                    : Colors.grey,
                              ),
                            ),
                            trailing: Icon(
                              Icons.edit_outlined,
                              size: 18,
                              color: isDark ? Colors.white54 : Colors.grey,
                            ),
                            onTap: () => _editarHorarioDia(diaKey, horario),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Grupo 3: Reportes, Conectividad y Cuenta
                  Text(
                    'Apariencia y Cuenta',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(height: 10),

                  CustomCard(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      children: [
                        _buildMenuTile(
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
                          onTap: () =>
                              _mostrarSelectorTema(context, currentTheme),
                          isDark: isDark,
                        ),
                        _buildDivider(isDark),
                        _buildMenuTile(
                          icon: Icons.table_chart_rounded,
                          iconColor: const Color(0xFF059669),
                          title: 'Exportar Registro a CSV / Excel',
                          subtitle: 'Generar reporte descargable de todas tus jornadas',
                          onTap: _exportarCsvDesdePerfil,
                          isDark: isDark,
                        ),

                        _buildDivider(isDark),
                        _buildMenuTile(
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
      ),
    );
  }

  // --- SUB-WIDGETS ---

  Widget _buildProfileHeader(Perfil perfil, String email, bool isDark) {
    final initials = perfil.nombre.trim().isNotEmpty
        ? perfil.nombre
              .trim()
              .split(' ')
              .take(2)
              .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
              .join()
        : 'P';

    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4F46E5),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    perfil.nombre,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    email.isNotEmpty ? email : 'Practicante Registrado',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiSummaryCards(Perfil perfil, bool isDark) {
    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: Row(
        children: [
          // Meta Total
          Expanded(
            child: _buildKpiBox(
              title: 'Meta Total',
              value: '${perfil.metaHorasTotal.toInt()}h',
              icon: Icons.flag_rounded,
              color: const Color(0xFF4F46E5),
              isDark: isDark,
              onTap: () => _editarMetaYHoras(perfil),
            ),
          ),
          const SizedBox(width: 10),
          // Min Semanal
          Expanded(
            child: _buildKpiBox(
              title: 'Mín. Semanal',
              value: '${perfil.horasMinimasSemanales.toInt()}h',
              icon: Icons.speed_rounded,
              color: const Color(0xFF0284C7),
              isDark: isDark,
              onTap: () => _editarMetaYHoras(perfil),
            ),
          ),
          const SizedBox(width: 10),
          // Horas Cursadas
          Expanded(
            child: _buildKpiBox(
              title: 'Cursadas',
              value: '${perfil.horasInicialesPrevias.toStringAsFixed(0)}h',
              icon: Icons.history_rounded,
              color: const Color(0xFF10B981),
              isDark: isDark,
              onTap: () => _editarMetaYHoras(perfil),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white60 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: isDestructive
              ? const Color(0xFFEF4444)
              : (isDark ? Colors.white : const Color(0xFF0F172A)),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: isDark ? Colors.white38 : Colors.grey.shade400,
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 64,
      endIndent: 16,
      color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
    );
  }
}

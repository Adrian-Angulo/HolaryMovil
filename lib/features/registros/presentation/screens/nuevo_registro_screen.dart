import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:practi_horas_app/core/constants/app_constants.dart';
import 'package:practi_horas_app/core/di/dependency_injection.dart';
import 'package:practi_horas_app/core/utils/date_formatters.dart';
import 'package:practi_horas_app/core/utils/time_calculator.dart';
import 'package:practi_horas_app/core/shared_atomic/atoms/custom_card.dart';
import 'package:practi_horas_app/features/registros/presentation/providers/registro_form_provider.dart';
import 'package:practi_horas_app/features/registros/presentation/providers/registro_provider.dart';
import 'package:practi_horas_app/features/registros/presentation/widgets/molecules/horas_live_preview.dart';

class NuevoRegistroScreen extends ConsumerStatefulWidget {
  final VoidCallback? onRegistroGuardado;

  const NuevoRegistroScreen({super.key, this.onRegistroGuardado});

  @override
  ConsumerState<NuevoRegistroScreen> createState() =>
      _NuevoRegistroScreenState();
}

class _NuevoRegistroScreenState extends ConsumerState<NuevoRegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _actividadesController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final formState = ref.read(registroFormNotifierProvider);
      _actividadesController.text = formState.actividades;
    });
  }

  @override
  void dispose() {
    _actividadesController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final formState = ref.read(registroFormNotifierProvider);
    final first = DateTime(2020);
    final last = DateTime(2035);
    final initial = formState.fecha;
    final validInitial = initial.isBefore(first)
        ? first
        : (initial.isAfter(last) ? last : initial);

    final picked = await showDatePicker(
      context: context,
      initialDate: validInitial,
      firstDate: first,
      lastDate: last,
      locale: const Locale('es', 'ES'),
      helpText: 'Fecha de la Jornada',
      cancelText: 'Cancelar',
      confirmText: 'Seleccionar',
    );

    if (picked != null) {
      ref.read(registroFormNotifierProvider.notifier).setFecha(picked);
    }
  }

  Future<void> _seleccionarHoraInicio(BuildContext context) async {
    final formState = ref.read(registroFormNotifierProvider);
    final initial = TimeCalculator.parseTimeOfDay(formState.horaInicio);

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final str = TimeCalculator.formatTimeOfDay(picked);
      ref.read(registroFormNotifierProvider.notifier).setHoraInicio(str);
    }
  }

  Future<void> _seleccionarHoraFin(BuildContext context) async {
    final formState = ref.read(registroFormNotifierProvider);
    final initial = TimeCalculator.parseTimeOfDay(formState.horaFin);

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final str = TimeCalculator.formatTimeOfDay(picked);
      ref.read(registroFormNotifierProvider.notifier).setHoraFin(str);
    }
  }

  Future<void> _dialogoDescansoPersonalizado(BuildContext context) async {
    final formState = ref.read(registroFormNotifierProvider);
    final currentMin = formState.descuentoAlmuerzoMinutos;
    final controller = TextEditingController(
      text: currentMin > 0 ? currentMin.toString() : '',
    );

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.restaurant_rounded, color: Color(0xFFF59E0B)),
            const SizedBox(width: 8),
            Text(
              'Tiempo de Descanso',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Indica los minutos dedicados a almuerzo o refrigerio para descontarlos de las horas de práctica:',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Minutos (0 a 180)',
                suffixText: 'min',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final val = int.tryParse(controller.text.trim()) ?? 0;
              Navigator.of(ctx).pop(val.clamp(0, 180));
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );

    if (result != null) {
      ref
          .read(registroFormNotifierProvider.notifier)
          .setDescuentoAlmuerzoMinutos(result);
    }
  }

  Future<void> _guardarRegistro() async {
    if (_isSaving) return;

    final formNotifier = ref.read(registroFormNotifierProvider.notifier);
    final formState = ref.read(registroFormNotifierProvider);

    if (_actividadesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Las actividades son obligatorias.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    formNotifier.setActividades(_actividadesController.text);

    if (formState.horasComputables <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️ Las horas computables deben ser mayores a 0. Verifica la hora de inicio y fin.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final entity = formNotifier.toEntity();

    // Validación de solapamiento de horarios (Regla de negocio)
    final listaRegistros = ref.read(registrosNotifierProvider).value ?? [];
    final conflicto = ref.read(validarSolapamientoUseCaseProvider).execute(
      registro: entity,
      registrosExistentes: listaRegistros,
    );

    if (conflicto != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ Conflicto de horario: Ya tienes una jornada registrada de ${conflicto.horaInicio} a ${conflicto.horaFin} en esta fecha.',
          ),
          backgroundColor: Colors.orange.shade900,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (formState.isEditing) {
        final failure = await ref.read(registrosNotifierProvider.notifier).actualizarRegistro(entity);
        if (mounted) {
          if (failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⚠️ ${failure.message}'),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Registro actualizado con éxito'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      } else {
        final failure = await ref.read(registrosNotifierProvider.notifier).agregarRegistro(entity);
        if (mounted) {
          if (failure != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⚠️ ${failure.message}'),
                backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 Jornada registrada correctamente'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      }

      formNotifier.inicializarConFecha(DateTime.now());
      _actividadesController.clear();

      widget.onRegistroGuardado?.call();
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(registroFormNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final diaKey = DateFormatters.getDiaSemanaKey(formState.fecha);
    final diaNombre = DateFormatters.getDiaNombre(diaKey);

    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(
          duration: const Duration(milliseconds: 350),
          child: Text(
            formState.isEditing ? 'Editar Jornada' : 'Registrar Horas',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
        ),
        actions: [
          if (formState.isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                ref
                    .read(registroFormNotifierProvider.notifier)
                    .inicializarConFecha(DateTime.now());
                _actividadesController.clear();
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(
                duration: const Duration(milliseconds: 400),
                child: CustomCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fecha de la Jornada',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          if (!formState.isDiaConfiguradoActivo)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Día no habitual',
                                style: GoogleFonts.inter(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () => _seleccionarFecha(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF0F172A)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFCBD5E1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                color: Color(0xFF4F46E5),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '${DateFormatters.fechaCompleta(formState.fecha)} ($diaNombre)',
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                duration: const Duration(milliseconds: 450),
                delay: const Duration(milliseconds: 100),
                child: CustomCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Horario de Trabajo',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _seleccionarHoraInicio(context),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.login_rounded,
                                          size: 14,
                                          color: Color(0xFF10B981),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Entrada',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      formState.horaInicio,
                                      style: GoogleFonts.inter(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _seleccionarHoraFin(context),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isDark
                                        ? const Color(0xFF334155)
                                        : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.logout_rounded,
                                          size: 14,
                                          color: Color(0xFFEF4444),
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Salida',
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      formState.horaFin,
                                      style: GoogleFonts.inter(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                duration: const Duration(milliseconds: 450),
                delay: const Duration(milliseconds: 150),
                child: CustomCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modalidad',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: AppConstants.modalidades.map((mod) {
                          final isSelected = formState.modalidad == mod;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: ChoiceChip(
                                label: Center(
                                  child: Text(
                                    mod,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : (isDark
                                                ? Colors.white70
                                                : Colors.black87),
                                    ),
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: const Color(0xFF4F46E5),
                                onSelected: (_) {
                                  ref
                                      .read(
                                        registroFormNotifierProvider.notifier,
                                      )
                                      .setModalidad(mod);
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                duration: const Duration(milliseconds: 450),
                delay: const Duration(milliseconds: 175),
                child: CustomCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.restaurant_rounded,
                                size: 18,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Descanso / Hora de Comida',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          if (formState.descuentoAlmuerzoMinutos > 0)
                            Text(
                              '-${formState.descuentoAlmuerzoMinutos} min',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFF59E0B),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text(
                              'Sin descanso (0m)',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: formState.descuentoAlmuerzoMinutos == 0
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: formState.descuentoAlmuerzoMinutos == 0
                                    ? Colors.white
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                            selected: formState.descuentoAlmuerzoMinutos == 0,
                            selectedColor: const Color(0xFF4F46E5),
                            onSelected: (_) {
                              ref
                                  .read(registroFormNotifierProvider.notifier)
                                  .setDescuentoAlmuerzoMinutos(0);
                            },
                          ),
                          ChoiceChip(
                            label: Text(
                              '30 min',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: formState.descuentoAlmuerzoMinutos == 30
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: formState.descuentoAlmuerzoMinutos == 30
                                    ? Colors.white
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                            selected: formState.descuentoAlmuerzoMinutos == 30,
                            selectedColor: const Color(0xFF4F46E5),
                            onSelected: (_) {
                              ref
                                  .read(registroFormNotifierProvider.notifier)
                                  .setDescuentoAlmuerzoMinutos(30);
                            },
                          ),
                          ChoiceChip(
                            label: Text(
                              '45 min',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: formState.descuentoAlmuerzoMinutos == 45
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: formState.descuentoAlmuerzoMinutos == 45
                                    ? Colors.white
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                            selected: formState.descuentoAlmuerzoMinutos == 45,
                            selectedColor: const Color(0xFF4F46E5),
                            onSelected: (_) {
                              ref
                                  .read(registroFormNotifierProvider.notifier)
                                  .setDescuentoAlmuerzoMinutos(45);
                            },
                          ),
                          ChoiceChip(
                            label: Text(
                              '1 hora (60m)',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: formState.descuentoAlmuerzoMinutos == 60
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: formState.descuentoAlmuerzoMinutos == 60
                                    ? Colors.white
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                            selected: formState.descuentoAlmuerzoMinutos == 60,
                            selectedColor: const Color(0xFF4F46E5),
                            onSelected: (_) {
                              ref
                                  .read(registroFormNotifierProvider.notifier)
                                  .setDescuentoAlmuerzoMinutos(60);
                            },
                          ),
                          ActionChip(
                            avatar: Icon(
                              Icons.edit_calendar_rounded,
                              size: 16,
                              color: ![0, 30, 45, 60].contains(formState.descuentoAlmuerzoMinutos)
                                  ? Colors.white
                                  : const Color(0xFF4F46E5),
                            ),
                            backgroundColor: ![0, 30, 45, 60].contains(formState.descuentoAlmuerzoMinutos)
                                ? const Color(0xFF4F46E5)
                                : null,
                            label: Text(
                              ![0, 30, 45, 60].contains(formState.descuentoAlmuerzoMinutos)
                                  ? 'Personalizado (${formState.descuentoAlmuerzoMinutos}m)'
                                  : 'Otro...',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: ![0, 30, 45, 60].contains(formState.descuentoAlmuerzoMinutos)
                                    ? Colors.white
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                            onPressed: () => _dialogoDescansoPersonalizado(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ZoomIn(
                duration: const Duration(milliseconds: 400),
                delay: const Duration(milliseconds: 200),
                child: HorasLivePreview(
                  horaInicio: formState.horaInicio,
                  horaFin: formState.horaFin,
                  horasComputables: formState.horasComputables,
                  descuentoMinutos: formState.descuentoAlmuerzoMinutos,
                ),
              ),
              const SizedBox(height: 16),
              FadeInUp(
                duration: const Duration(milliseconds: 450),
                delay: const Duration(milliseconds: 250),
                child: CustomCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Actividades Realizadas',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _actividadesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Ej: Desarrollo del módulo de autenticación, reunión con el supervisor...',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeInUp(
                duration: const Duration(milliseconds: 450),
                delay: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _guardarRegistro,
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                formState.isEditing
                                    ? Icons.check_circle_rounded
                                    : Icons.save_rounded,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formState.isEditing
                                    ? 'Actualizar Registro'
                                    : 'Guardar Jornada',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

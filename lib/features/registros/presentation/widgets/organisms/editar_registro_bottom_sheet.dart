import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:practi_horas_app/core/constants/app_constants.dart';
import 'package:practi_horas_app/core/di/dependency_injection.dart';
import 'package:practi_horas_app/core/theme/app_colors.dart';
import 'package:practi_horas_app/core/utils/date_formatters.dart';
import 'package:practi_horas_app/core/utils/time_calculator.dart';
import 'package:practi_horas_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:practi_horas_app/features/registros/domain/entities/registro_hora.dart';
import 'package:practi_horas_app/features/registros/presentation/providers/registro_provider.dart';

/// Modal BottomSheet desacoplado para la edición intuitiva de una jornada.
/// Aplica Single Responsibility (SRP) y no muta el formulario global de nuevos registros.
class EditarRegistroBottomSheet extends ConsumerStatefulWidget {
  final RegistroHora registro;

  const EditarRegistroBottomSheet({super.key, required this.registro});

  /// Muestra el BottomSheet de forma limpia desde cualquier pantalla
  static Future<bool?> show(
    BuildContext context, {
    required RegistroHora registro,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditarRegistroBottomSheet(registro: registro),
    );
  }

  @override
  ConsumerState<EditarRegistroBottomSheet> createState() =>
      _EditarRegistroBottomSheetState();
}

class _EditarRegistroBottomSheetState
    extends ConsumerState<EditarRegistroBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _fecha;
  late String _horaInicio;
  late String _horaFin;
  late int _descuentoAlmuerzoMinutos;
  late String _modalidad;
  late final TextEditingController _actividadesController;
  late final TextEditingController _descuentoCustomController;

  bool _isSaving = false;
  bool _isCustomDescuento = false;

  @override
  void initState() {
    super.initState();
    final reg = widget.registro;
    _fecha = reg.fecha;
    _horaInicio = reg.horaInicio;
    _horaFin = reg.horaFin;
    _descuentoAlmuerzoMinutos = reg.descuentoAlmuerzoMinutos;
    _modalidad = reg.modalidad;
    _actividadesController = TextEditingController(text: reg.actividades);
    _descuentoCustomController = TextEditingController(
      text: _descuentoAlmuerzoMinutos.toString(),
    );

    final standardChips = [0, 30, 45, 60];
    if (!standardChips.contains(_descuentoAlmuerzoMinutos)) {
      _isCustomDescuento = true;
    }
  }

  @override
  void dispose() {
    _actividadesController.dispose();
    _descuentoCustomController.dispose();
    super.dispose();
  }

  double get _horasComputables {
    return TimeCalculator.calcularHorasNetas(
      _horaInicio,
      _horaFin,
      _descuentoAlmuerzoMinutos,
    );
  }

  Future<void> _seleccionarFecha() async {
    final first = DateTime(2020);
    final last = DateTime(2035);
    final initial = _fecha.isBefore(first)
        ? first
        : (_fecha.isAfter(last) ? last : _fecha);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      locale: const Locale('es', 'ES'),
      helpText: 'Fecha de la Jornada',
      cancelText: 'Cancelar',
      confirmText: 'Seleccionar',
    );

    if (picked != null) {
      setState(() => _fecha = picked);
    }
  }

  Future<void> _seleccionarHoraInicio() async {
    final initial = TimeCalculator.parseTimeOfDay(_horaInicio);

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
      setState(() {
        _horaInicio = TimeCalculator.formatTimeOfDay(picked);
      });
    }
  }

  Future<void> _seleccionarHoraFin() async {
    final initial = TimeCalculator.parseTimeOfDay(_horaFin);

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
      setState(() {
        _horaFin = TimeCalculator.formatTimeOfDay(picked);
      });
    }
  }

  Future<void> _guardarEdicion() async {
    if (_isSaving) return;

    final actividades = _actividadesController.text.trim();
    if (actividades.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Las actividades son obligatorias.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_horasComputables <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '⚠️ Las horas computables deben ser mayores a 0. Verifica la hora de entrada, salida y almuerzo.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final updatedEntity = widget.registro.copyWith(
      fecha: _fecha,
      horaInicio: _horaInicio,
      horaFin: _horaFin,
      descuentoAlmuerzoMinutos: _descuentoAlmuerzoMinutos,
      horasComputables: _horasComputables,
      modalidad: _modalidad,
      actividades: actividades,
    );

    // Validación de solapamiento (SRP / OCP vía UseCase)
    final listaRegistros = ref.read(registrosNotifierProvider).value ?? [];
    final conflicto = ref
        .read(validarSolapamientoUseCaseProvider)
        .execute(registro: updatedEntity, registrosExistentes: listaRegistros);

    if (conflicto != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '⚠️ Conflicto de horario: Ya tienes una jornada de ${conflicto.horaInicio} a ${conflicto.horaFin} en esta fecha.',
          ),
          backgroundColor: Colors.orange.shade900,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final failure = await ref
          .read(registrosNotifierProvider.notifier)
          .actualizarRegistro(updatedEntity);

      if (!mounted) return;

      if (failure != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ ${failure.message}'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // Invalidar métricas para actualización reactiva en Dashboard
      ref.invalidate(dashboardMetricsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Jornada actualizada correctamente'),
          backgroundColor: Color(0xFF10B981),
        ),
      );

      Navigator.of(context).pop(true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final diaKey = DateFormatters.getDiaSemanaKey(_fecha);
    final diaNombre = DateFormatters.getDiaNombre(diaKey);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Indicador de arrastre (Drag handle)
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),

                // Encabezado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.edit_calendar_rounded,
                            color: primaryColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Editar Jornada',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Ajusta los detalles de este registro',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isDark
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Selector de Fecha
                Text(
                  'Fecha',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                InkWell(
                  onTap: _seleccionarFecha,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          color: primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${DateFormatters.fechaCompleta(_fecha)} ($diaNombre)',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Selector de Horas (Entrada y Salida)
                Text(
                  'Horario de Trabajo',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeBox(
                        label: 'Entrada',
                        value: _horaInicio,
                        icon: Icons.login_rounded,
                        onTap: _seleccionarHoraInicio,
                        isDark: isDark,
                        primaryColor: primaryColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeBox(
                        label: 'Salida',
                        value: _horaFin,
                        icon: Icons.logout_rounded,
                        onTap: _seleccionarHoraFin,
                        isDark: isDark,
                        primaryColor: primaryColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Descuento Almuerzo / Refrigerio
                Text(
                  'Descuento por Almuerzo / Pausa',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildDescuentoChip(
                      minutos: 0,
                      label: 'Sin pausa (0m)',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                    _buildDescuentoChip(
                      minutos: 30,
                      label: '30 min',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                    _buildDescuentoChip(
                      minutos: 45,
                      label: '45 min',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                    _buildDescuentoChip(
                      minutos: 60,
                      label: '1 hora (60m)',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                    _buildDescuentoChip(
                      minutos: 120,
                      label: '2 horas (120m)',
                      isDark: isDark,
                      primaryColor: primaryColor,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Modalidad
                Text(
                  'Modalidad',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: AppConstants.modalidades.map((mod) {
                    final isSelected = _modalidad == mod;
                    final isPresencial = mod == 'Presencial';
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: isPresencial ? 8 : 0,
                          left: !isPresencial ? 8 : 0,
                        ),
                        child: InkWell(
                          onTap: () => setState(() => _modalidad = mod),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor.withValues(alpha: 0.15)
                                  : (isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFF8FAFC)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : (isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE2E8F0)),
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isPresencial
                                      ? Icons.apartment_rounded
                                      : Icons.home_work_rounded,
                                  size: 16,
                                  color: isSelected
                                      ? primaryColor
                                      : (isDark
                                            ? const Color(0xFF94A3B8)
                                            : const Color(0xFF64748B)),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  mod,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? primaryColor
                                        : (isDark
                                              ? Colors.white
                                              : const Color(0xFF0F172A)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Actividades Realizadas
                Text(
                  'Actividades / Tareas',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _actividadesController,
                  maxLines: 3,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Describe brevemente lo trabajado hoy...',
                    hintStyle: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primaryColor, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Tarjeta de Horas Computables (Feedback en vivo)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _horasComputables > 0
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.redAccent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _horasComputables > 0
                          ? AppColors.primary.withValues(alpha: 0.3)
                          : Colors.redAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _horasComputables > 0
                                ? Icons.timer_outlined
                                : Icons.warning_amber_rounded,
                            color: _horasComputables > 0
                                ? AppColors.primary
                                : Colors.redAccent,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Horas Computables:',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${_horasComputables.toStringAsFixed(1)} horas',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _horasComputables > 0
                              ? AppColors.primary
                              : Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _guardarEdicion,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_rounded, size: 20),
                        label: Text(
                          _isSaving ? 'Guardando...' : 'Guardar Cambios',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeBox({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    required Color primaryColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: primaryColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescuentoChip({
    required int minutos,
    required String label,
    required bool isDark,
    required Color primaryColor,
  }) {
    final isSelected =
        !_isCustomDescuento && _descuentoAlmuerzoMinutos == minutos;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected
            ? Colors.white
            : (isDark ? Colors.white : const Color(0xFF0F172A)),
      ),
      selectedColor: primaryColor,
      backgroundColor: isDark
          ? const Color(0xFF1E293B)
          : const Color(0xFFF1F5F9),
      showCheckmark: false,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _isCustomDescuento = false;
            _descuentoAlmuerzoMinutos = minutos;
          });
        }
      },
    );
  }
}

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/shared_atomic/atoms/custom_card.dart';
import '../../../../core/utils/date_formatters.dart';
import '../../../../core/utils/time_calculator.dart';
import '../../../shell/presentation/screens/home_navigation_screen.dart';
import '../../domain/entities/horario_dia.dart';
import '../../domain/entities/perfil.dart';
import '../providers/perfil_provider.dart';

class RegistroPerfilScreen extends ConsumerStatefulWidget {
  const RegistroPerfilScreen({super.key});

  @override
  ConsumerState<RegistroPerfilScreen> createState() =>
      _RegistroPerfilScreenState();
}

class _RegistroPerfilScreenState extends ConsumerState<RegistroPerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _metaHorasController;
  late TextEditingController _horasPreviasController;
  late TextEditingController _horasMinimasController;

  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  late Map<String, HorarioDia> _horarioSemanal;

  @override
  void initState() {
    super.initState();
    final defaultPerfil = Perfil.defaultPerfil();
    final registeredName = ref.read(sessionStorageProvider).getUserName() ?? '';
    _nombreController = TextEditingController(text: registeredName);
    _metaHorasController = TextEditingController(text: '360');
    _horasPreviasController = TextEditingController(text: '0');
    _horasMinimasController = TextEditingController(text: '30');

    _fechaInicio = defaultPerfil.fechaInicio;
    _fechaFin = defaultPerfil.fechaFin;
    _horarioSemanal = Map<String, HorarioDia>.from(
      defaultPerfil.horarioSemanal,
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _metaHorasController.dispose();
    _horasPreviasController.dispose();
    _horasMinimasController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFechaInicio() async {
    final now = DateTime.now();
    final initial = _fechaInicio ?? now;
    final first = DateTime(2020);
    final last = DateTime(2035);
    final validInitial = initial.isBefore(first)
        ? first
        : (initial.isAfter(last) ? last : initial);

    final picked = await showDatePicker(
      context: context,
      initialDate: validInitial,
      firstDate: first,
      lastDate: last,
      locale: const Locale('es', 'ES'),
      helpText: 'Fecha de Inicio de Prácticas',
      cancelText: 'Cancelar',
      confirmText: 'Seleccionar',
    );
    if (picked != null) {
      setState(() {
        _fechaInicio = picked;
        if (_fechaFin != null && _fechaFin!.isBefore(picked)) {
          _fechaFin = picked.add(const Duration(days: 90));
        }
      });
    }
  }

  Future<void> _seleccionarFechaFin() async {
    final now = DateTime.now();
    final initial =
        _fechaFin ??
        (_fechaInicio != null
            ? _fechaInicio!.add(const Duration(days: 90))
            : now.add(const Duration(days: 90)));
    final first = _fechaInicio ?? DateTime(2020);
    final last = DateTime(2035);
    final validInitial = initial.isBefore(first)
        ? first
        : (initial.isAfter(last) ? last : initial);

    final picked = await showDatePicker(
      context: context,
      initialDate: validInitial,
      firstDate: first,
      lastDate: last,
      locale: const Locale('es', 'ES'),
      helpText: 'Fecha de Fin de Prácticas',
      cancelText: 'Cancelar',
      confirmText: 'Seleccionar',
    );
    if (picked != null) {
      setState(() => _fechaFin = picked);
    }
  }

  Future<void> _editarHorarioDia(String diaKey) async {
    final horario =
        _horarioSemanal[diaKey] ??
        HorarioDia(
          diaSemana: diaKey,
          activo: false,
          horaInicio: '08:00',
          horaFin: '13:00',
          refrigerioMinutos: 0,
          modalidad: 'Presencial',
        );

    bool activo = horario.activo;
    String horaInicio = horario.horaInicio;
    String horaFin = horario.horaFin;
    String modalidad = horario.modalidad;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Configurar ${DateFormatters.getDiaNombre(diaKey)}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Switch(
                        value: activo,
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
                    const Text('Modalidad', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: AppConstants.modalidades.map((mod) {
                        return ChoiceChip(
                          label: Text(mod),
                          selected: modalidad == mod,
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
                          'Día no laboral / descanso',
                          style: GoogleFonts.inter(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _horarioSemanal[diaKey] = horario.copyWith(
                            activo: activo,
                            horaInicio: horaInicio,
                            horaFin: horaFin,
                            refrigerioMinutos: 0,
                            modalidad: modalidad,
                          );
                        });
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Aceptar'),
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

  Future<void> _guardarYContinuar() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombreController.text.trim().isEmpty
        ? 'Practicante'
        : _nombreController.text.trim();
    final metaHoras =
        double.tryParse(_metaHorasController.text.trim()) ?? 360.0;
    final horasPrevias =
        double.tryParse(_horasPreviasController.text.trim()) ?? 0.0;
    final horasMinimas =
        double.tryParse(_horasMinimasController.text.trim()) ?? 30.0;

    await ref
        .read(perfilNotifierProvider.notifier)
        .guardarPerfilInicial(
          nombre: nombre,
          metaHoras: metaHoras,
          horasInicialesPrevias: horasPrevias,
          horasMinimasSemanales: horasMinimas,
          fechaInicio: _fechaInicio,
          fechaFin: _fechaFin,
          horarioSemanal: _horarioSemanal,
        );

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeNavigationScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                FadeInDown(
                  duration: const Duration(milliseconds: 400),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5)
                                .withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.person_pin_rounded,
                                    size: 36,
                                    color: Color(0xFF4F46E5),
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '¡Bienvenido a Horaly!',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Configura tu perfil de prácticas para comenzar',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 1. Datos Personales y Metas
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 100),
                  child: CustomCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Información del Practicante',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre Completo del Practicante',
                            hintText: 'Ej. Juan Carlos Pérez Quispe',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Ingresa tus nombres y apellidos';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _metaHorasController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Horas Totales',
                                  hintText: '360',
                                  prefixIcon: Icon(Icons.flag_outlined),
                                  suffixText: 'hrs',
                                ),
                                validator: (val) {
                                  final num = double.tryParse(val ?? '');
                                  if (num == null || num <= 0) {
                                    return 'Ingresa meta válida';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _horasMinimasController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Mínimo Semanal',
                                  hintText: '30',
                                  prefixIcon: Icon(Icons.timelapse_rounded),
                                  suffixText: 'hrs',
                                ),
                                validator: (val) {
                                  final num = double.tryParse(val ?? '');
                                  if (num == null || num <= 0) {
                                    return 'Ingresa horas';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _horasPreviasController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Horas Ya Cursadas (Opcional)',
                            hintText: '0',
                            prefixIcon: Icon(Icons.history_edu_rounded),
                            suffixText: 'hrs',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Periodo de Prácticas
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 200),
                  child: CustomCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Periodo de Prácticas (Opcional)',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Nos ayuda a calcular si vas adelantado, a tiempo o con atraso.',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _seleccionarFechaInicio,
                                child: Text(
                                  _fechaInicio != null
                                      ? 'Inicio: ${DateFormatters.fechaCorta(_fechaInicio!)}'
                                      : 'Fecha Inicio',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _seleccionarFechaFin,
                                child: Text(
                                  _fechaFin != null
                                      ? 'Fin: ${DateFormatters.fechaCorta(_fechaFin!)}'
                                      : 'Fecha Fin',
                                  style: const TextStyle(fontSize: 12),
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

                // 3. Horario Semanal Habitual
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 300),
                  child: CustomCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Horario Semanal Habitual',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Toca para ajustar',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF4F46E5),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ...AppConstants.diasSemanaKeys.map((diaKey) {
                          final h =
                              _horarioSemanal[diaKey] ??
                              HorarioDia(
                                diaSemana: diaKey,
                                activo: false,
                                horaInicio: '08:00',
                                horaFin: '13:00',
                                refrigerioMinutos: 0,
                                modalidad: 'Presencial',
                              );

                          return InkWell(
                            onTap: () => _editarHorarioDia(diaKey),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 4,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: h.activo
                                          ? const Color(0xFF10B981)
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    DateFormatters.getDiaNombre(diaKey),
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    h.activo
                                        ? '${h.horaInicio} - ${h.horaFin}'
                                        : 'No laboral',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: h.activo
                                          ? (isDark
                                                ? const Color(0xFFE2E8F0)
                                                : const Color(0xFF334155))
                                          : (isDark
                                                ? const Color(0xFF64748B)
                                                : const Color(0xFF94A3B8)),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.edit_outlined,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // 4. Botón de Iniciar
                FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 400),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _guardarYContinuar,
                      child: Text(
                        'Comenzar a Registrar Horas',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
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
}

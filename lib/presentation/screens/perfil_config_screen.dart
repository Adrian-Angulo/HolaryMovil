import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/utils/time_calculator.dart';
import '../../domain/entities/horario_dia.dart';
import '../providers/perfil_provider.dart';
import '../widgets/common/custom_card.dart';

class PerfilConfigScreen extends ConsumerStatefulWidget {
  const PerfilConfigScreen({super.key});

  @override
  ConsumerState<PerfilConfigScreen> createState() => _PerfilConfigScreenState();
}

class _PerfilConfigScreenState extends ConsumerState<PerfilConfigScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _metaController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _metaController = TextEditingController();

    final perfil = ref.read(perfilNotifierProvider).value;
    if (perfil != null) {
      _nombreController.text = perfil.nombre;
      _metaController.text = perfil.metaHorasTotal.toString();
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _metaController.dispose();
    super.dispose();
  }

  Future<void> _guardarDatosGenerales() async {
    final nombre = _nombreController.text.trim();
    final meta = double.tryParse(_metaController.text.trim()) ?? 360.0;

    await ref.read(perfilNotifierProvider.notifier).updateNombreYMeta(
          nombre: nombre.isEmpty ? 'Practicante' : nombre,
          metaHoras: meta,
        );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Configuración guardada'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  Future<void> _editarHorarioDia(String diaKey, HorarioDia horario) async {
    bool activo = horario.activo;
    String horaInicio = horario.horaInicio;
    String horaFin = horario.horaFin;
    int refrigerio = horario.refrigerioMinutos;
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
                    // Horas de inicio y fin
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Hora Inicio', style: TextStyle(fontSize: 12)),
                            subtitle: Text(
                              horaInicio,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            onTap: () async {
                              final initial = TimeCalculator.parseTimeOfDay(horaInicio);
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: initial,
                              );
                              if (picked != null) {
                                setModalState(() {
                                  horaInicio = TimeCalculator.formatTimeOfDay(picked);
                                });
                              }
                            },
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Hora Fin', style: TextStyle(fontSize: 12)),
                            subtitle: Text(
                              horaFin,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            onTap: () async {
                              final initial = TimeCalculator.parseTimeOfDay(horaFin);
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: initial,
                              );
                              if (picked != null) {
                                setModalState(() {
                                  horaFin = TimeCalculator.formatTimeOfDay(picked);
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Refrigerio
                    const Text('Refrigerio (Descuento en minutos)', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [0, 30, 45, 60].map((m) {
                        return ChoiceChip(
                          label: Text(m == 0 ? 'Sin desc.' : '$m min'),
                          selected: refrigerio == m,
                          onSelected: (_) => setModalState(() => refrigerio = m),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    // Modalidad
                    const Text('Modalidad Predeterminada', style: TextStyle(fontSize: 12)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: AppConstants.modalidades.map((mod) {
                        return ChoiceChip(
                          label: Text(mod),
                          selected: modalidad == mod,
                          onSelected: (_) => setModalState(() => modalidad = mod),
                        );
                      }).toList(),
                    ),
                  ] else ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Este día está marcado como no laboral.',
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
                        final updated = horario.copyWith(
                          activo: activo,
                          horaInicio: horaInicio,
                          horaFin: horaFin,
                          refrigerioMinutos: refrigerio,
                          modalidad: modalidad,
                        );
                        ref.read(perfilNotifierProvider.notifier).updateHorarioDia(diaKey, updated);
                        Navigator.of(ctx).pop();
                      },
                      child: const Text('Guardar Horario del Día'),
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

  @override
  Widget build(BuildContext context) {
    final perfilAsync = ref.watch(perfilNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ref.listen(perfilNotifierProvider, (previous, next) {
      if (next.hasValue && _nombreController.text.isEmpty) {
        _nombreController.text = next.value!.nombre;
        _metaController.text = next.value!.metaHorasTotal.toString();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(
          duration: const Duration(milliseconds: 350),
          child: Text(
            'Ajustes y Perfil',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      body: perfilAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (perfil) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Datos del Practicante con FadeInDown
                FadeInDown(
                  duration: const Duration(milliseconds: 450),
                  child: CustomCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Datos del Practicante',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _nombreController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre / Alias',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _metaController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Meta Total de Horas',
                            prefixIcon: Icon(Icons.flag_outlined),
                            suffixText: 'hrs',
                          ),
                        ),
                        const SizedBox(height: 14),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.tonal(
                            onPressed: _guardarDatosGenerales,
                            child: const Text('Actualizar Datos'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Horario Semanal Habitual con FadeInUp
                FadeIn(
                  duration: const Duration(milliseconds: 400),
                  delay: const Duration(milliseconds: 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Horario Semanal Predeterminado',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Estos horarios se auto-completarán al seleccionar una fecha en el registro.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                ...List.generate(AppConstants.diasSemanaKeys.length, (index) {
                  final diaKey = AppConstants.diasSemanaKeys[index];
                  final horario = perfil.horarioSemanal[diaKey] ??
                      HorarioDia(
                        diaSemana: diaKey,
                        activo: false,
                        horaInicio: '08:00',
                        horaFin: '13:00',
                        refrigerioMinutos: 0,
                        modalidad: 'Presencial',
                      );

                  final delayMs = (200 + (index * 40)).clamp(0, 500);

                  return FadeInUp(
                    duration: const Duration(milliseconds: 350),
                    delay: Duration(milliseconds: delayMs),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CustomCard(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        onTap: () => _editarHorarioDia(diaKey, horario),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: horario.activo ? const Color(0xFF10B981) : Colors.grey.shade400,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormatters.getDiaNombre(diaKey),
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    horario.activo
                                        ? '${horario.horaInicio} - ${horario.horaFin} • ${horario.modalidad}'
                                        : 'No laboral / descanso',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
}

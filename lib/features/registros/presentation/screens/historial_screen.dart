import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:practi_horas_app/core/constants/app_constants.dart';
import 'package:practi_horas_app/core/utils/csv_exporter.dart';
import 'package:practi_horas_app/core/utils/date_formatters.dart';
import 'package:practi_horas_app/core/shared_atomic/atoms/custom_card.dart';
import 'package:practi_horas_app/features/perfil/presentation/providers/perfil_provider.dart';
import 'package:practi_horas_app/features/registros/domain/entities/registro_hora.dart';
import 'package:practi_horas_app/features/registros/presentation/providers/registro_form_provider.dart';
import 'package:practi_horas_app/features/registros/presentation/providers/registro_provider.dart';

class HistorialScreen extends ConsumerWidget {
  final Function(RegistroHora)? onEditRegistro;

  const HistorialScreen({super.key, this.onEditRegistro});

  Future<void> _exportarCsv(BuildContext context, WidgetRef ref) async {
    final todosLosRegistros = ref.read(registrosNotifierProvider).value ?? [];
    final perfil = ref.read(perfilNotifierProvider).value;
    final horasPrevias = perfil?.horasInicialesPrevias ?? 0.0;
    final nombre = perfil?.nombre ?? 'Practicante';

    if (todosLosRegistros.isEmpty && horasPrevias == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ No hay registros de horas para exportar'),
          backgroundColor: Colors.amber,
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
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.table_chart_rounded,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exportar Reporte CSV',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Compatible con Excel y Google Sheets',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Formato: Fecha • Entrada • Salida • Actividades • Horas • Sumatoria (∑)\nTotal a exportar: ${todosLosRegistros.length} registros (${todosLosRegistros.fold<double>(horasPrevias, (prev, r) => prev + r.horasComputables).toStringAsFixed(2)} hrs totales)',
                  style: GoogleFonts.inter(fontSize: 11, height: 1.4),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await CsvExporter.exportarYCompartirCsv(
                      registros: todosLosRegistros,
                      horasInicialesPrevias: horasPrevias,
                      nombrePracticante: nombre,
                    );
                  },
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: const Text('Compartir / Guardar Archivo CSV'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await CsvExporter.copiarCsvAlPortapapeles(
                      registros: todosLosRegistros,
                      horasInicialesPrevias: horasPrevias,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('📋 CSV copiado al portapapeles'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copiar Texto CSV'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmarEliminar(
    BuildContext context,
    WidgetRef ref,
    RegistroHora registro,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          '¿Eliminar Registro?',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Se eliminará la jornada del ${DateFormatters.fechaCompleta(registro.fecha)} (${registro.horasComputables} horas). Esta acción no se puede deshacer.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final failure = await ref
          .read(registrosNotifierProvider.notifier)
          .eliminarRegistro(registro.id);
      if (context.mounted) {
        if (failure != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ ${failure.message}'),
              backgroundColor: Colors.redAccent,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🗑️ Registro eliminado'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrosFiltrados = ref.watch(historialFiltradoProvider);
    final modalidadFiltro = ref.watch(historialFiltroModalidadProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    double totalHorasFiltradas = 0.0;
    for (final reg in registrosFiltrados) {
      totalHorasFiltradas += reg.horasComputables;
    }

    return Scaffold(
      appBar: AppBar(
        title: FadeInDown(
          duration: const Duration(milliseconds: 350),
          child: Text(
            'Historial de Horas',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Exportar Reporte CSV',
            onPressed: () => _exportarCsv(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          FadeInDown(
            duration: const Duration(milliseconds: 400),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Todas'),
                    selected: modalidadFiltro == null,
                    onSelected: (_) {
                      ref
                              .read(historialFiltroModalidadProvider.notifier)
                              .state =
                          null;
                    },
                  ),
                  const SizedBox(width: 8),
                  ...AppConstants.modalidades.map((mod) {
                    final isSelected = modalidadFiltro == mod;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(mod),
                        selected: isSelected,
                        onSelected: (selected) {
                          ref
                              .read(historialFiltroModalidadProvider.notifier)
                              .state = selected
                              ? mod
                              : null;
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          FadeIn(
            duration: const Duration(milliseconds: 400),
            delay: const Duration(milliseconds: 100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${registrosFiltrados.length} ${registrosFiltrados.length == 1 ? 'jornada' : 'jornadas'}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    'Total: ${totalHorasFiltradas.toStringAsFixed(2)} hrs',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF4F46E5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: registrosFiltrados.isEmpty
                ? FadeIn(
                    duration: const Duration(milliseconds: 450),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_toggle_off_rounded,
                            size: 64,
                            color: isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFFCBD5E1),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No hay jornadas registradas',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tus horas registradas aparecerán aquí',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark
                                  ? const Color(0xFF64748B)
                                  : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: registrosFiltrados.length,
                    itemBuilder: (context, index) {
                      final reg = registrosFiltrados[index];
                      final delayMs = (index * 40).clamp(0, 400);

                      return FadeInUp(
                        duration: const Duration(milliseconds: 350),
                        delay: Duration(milliseconds: delayMs),
                        child: _buildHistorialItem(context, ref, reg),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorialItem(
    BuildContext context,
    WidgetRef ref,
    RegistroHora reg,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color badgeColor;
    switch (reg.modalidad) {
      case 'Remoto':
        badgeColor = const Color(0xFF06B6D4);
        break;
      case 'Híbrido':
        badgeColor = const Color(0xFF8B5CF6);
        break;
      default:
        badgeColor = const Color(0xFF4F46E5);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CustomCard(
        padding: const EdgeInsets.all(14),
        child: InkWell(
          onTap: () => _mostrarDetalleJornada(context, ref, reg),
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          reg.modalidad,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: badgeColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormatters.fechaCorta(reg.fecha),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${reg.horasComputables} hrs',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${reg.horaInicio} - ${reg.horaFin}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF94A3B8)
                          : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              if (reg.actividades.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  reg.actividades,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF334155),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarDetalleJornada(
    BuildContext context,
    WidgetRef ref,
    RegistroHora reg,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 70,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detalle de Jornada',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4F46E5),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormatters.fechaCompleta(reg.fecha),
                          style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${reg.horasComputables} hrs',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildDetailChip(
                    context,
                    icon: Icons.login_rounded,
                    label: 'Entrada',
                    value: reg.horaInicio,
                  ),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    context,
                    icon: Icons.logout_rounded,
                    label: 'Salida',
                    value: reg.horaFin,
                  ),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    context,
                    icon: Icons.work_outline_rounded,
                    label: 'Modalidad',
                    value: reg.modalidad,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Actividades Realizadas',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  reg.actividades.isNotEmpty
                      ? reg.actividades
                      : 'Sin actividades detalladas.',
                  style: GoogleFonts.inter(fontSize: 14, height: 1.4),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        textStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.edit_rounded, size: 20),
                      label: const Text('Editar'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        ref
                            .read(registroFormNotifierProvider.notifier)
                            .cargarParaEdicion(reg);
                        onEditRegistro?.call(reg);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .errorContainer,
                        foregroundColor: Theme.of(context)
                            .colorScheme
                            .onErrorContainer,
                        textStyle: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.delete_forever_rounded, size: 20),
                      label: const Text('Eliminar'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _confirmarEliminar(context, ref, reg);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 12, color: const Color(0xFF4F46E5)),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

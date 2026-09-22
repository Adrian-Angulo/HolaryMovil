import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatters.dart';
import '../../domain/entities/registro_hora.dart';
import '../providers/registro_form_provider.dart';
import '../providers/registro_provider.dart';
import '../widgets/common/custom_card.dart';

class HistorialScreen extends ConsumerWidget {
  final Function(RegistroHora)? onEditRegistro;

  const HistorialScreen({
    super.key,
    this.onEditRegistro,
  });

  Future<void> _confirmarEliminar(BuildContext context, WidgetRef ref, RegistroHora registro) async {
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
      await ref.read(registrosNotifierProvider.notifier).deleteRegistro(registro.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Registro eliminado'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrosFiltrados = ref.watch(historialFiltradoProvider);
    final modalidadFiltro = ref.watch(historialFiltroModalidadProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calcular total de horas del filtro actual
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
      ),
      body: Column(
        children: [
          // 1. Barra de Filtros de Modalidad con FadeInDown
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
                      ref.read(historialFiltroModalidadProvider.notifier).state = null;
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
                          ref.read(historialFiltroModalidadProvider.notifier).state =
                              selected ? mod : null;
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // 2. Resumen del Filtro con FadeIn
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
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
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

          // 3. Lista de Jornadas con Animación Escalonada
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
                            color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No hay jornadas registradas',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tus horas registradas aparecerán aquí',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildHistorialItem(BuildContext context, WidgetRef ref, RegistroHora reg) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dismissible(
      key: Key(reg.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _confirmarEliminar(context, ref, reg);
        return false; // El borrado real se maneja en el diálogo
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: CustomCard(
          padding: const EdgeInsets.all(14),
          onTap: () {
            ref.read(registroFormNotifierProvider.notifier).cargarParaEdicion(reg);
            onEditRegistro?.call(reg);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          color: Color(0xFF4F46E5),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        DateFormatters.fechaCompleta(reg.fecha),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${reg.horasComputables} hrs',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildTag(
                    icon: Icons.access_time_rounded,
                    label: '${reg.horaInicio} - ${reg.horaFin}',
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _buildTag(
                    icon: Icons.business_rounded,
                    label: reg.modalidad,
                    isDark: isDark,
                  ),
                  if (reg.descuentoAlmuerzoMinutos > 0) ...[
                    const SizedBox(width: 8),
                    _buildTag(
                      icon: Icons.restaurant_rounded,
                      label: '-${reg.descuentoAlmuerzoMinutos}m',
                      isDark: isDark,
                    ),
                  ],
                ],
              ),
              if (reg.actividades.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Text(
                    reg.actividades,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag({required IconData icon, required String label, required bool isDark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

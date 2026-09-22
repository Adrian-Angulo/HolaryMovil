import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/utils/time_calculator.dart';
import '../../domain/entities/registro_hora.dart';
import 'perfil_provider.dart';

class RegistroFormState {
  final String? id;
  final DateTime fecha;
  final String horaInicio;
  final String horaFin;
  final int descuentoAlmuerzoMinutos;
  final String modalidad;
  final String actividades;
  final double horasComputables;
  final bool isEditing;
  final bool isDiaConfiguradoActivo;

  const RegistroFormState({
    this.id,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.descuentoAlmuerzoMinutos,
    required this.modalidad,
    required this.actividades,
    required this.horasComputables,
    required this.isEditing,
    this.isDiaConfiguradoActivo = true,
  });

  RegistroFormState copyWith({
    String? id,
    DateTime? fecha,
    String? horaInicio,
    String? horaFin,
    int? descuentoAlmuerzoMinutos,
    String? modalidad,
    String? actividades,
    double? horasComputables,
    bool? isEditing,
    bool? isDiaConfiguradoActivo,
  }) {
    return RegistroFormState(
      id: id ?? this.id,
      fecha: fecha ?? this.fecha,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      descuentoAlmuerzoMinutos: descuentoAlmuerzoMinutos ?? this.descuentoAlmuerzoMinutos,
      modalidad: modalidad ?? this.modalidad,
      actividades: actividades ?? this.actividades,
      horasComputables: horasComputables ?? this.horasComputables,
      isEditing: isEditing ?? this.isEditing,
      isDiaConfiguradoActivo: isDiaConfiguradoActivo ?? this.isDiaConfiguradoActivo,
    );
  }
}

class RegistroFormNotifier extends StateNotifier<RegistroFormState> {
  final Ref _ref;

  RegistroFormNotifier(this._ref)
      : super(RegistroFormState(
          fecha: DateTime.now(),
          horaInicio: '08:00',
          horaFin: '13:00',
          descuentoAlmuerzoMinutos: 0,
          modalidad: 'Presencial',
          actividades: '',
          horasComputables: 5.0,
          isEditing: false,
        )) {
    inicializarConFecha(DateTime.now());
  }

  void inicializarConFecha(DateTime fecha) {
    final diaKey = DateFormatters.getDiaSemanaKey(fecha);
    final perfilAsync = _ref.read(perfilNotifierProvider);
    final perfil = perfilAsync.value;

    String inicio = '08:00';
    String fin = '13:00';
    int refrigerio = 0;
    String mod = 'Presencial';
    bool activo = true;

    if (perfil != null && perfil.horarioSemanal.containsKey(diaKey)) {
      final horarioDia = perfil.horarioSemanal[diaKey]!;
      inicio = horarioDia.horaInicio;
      fin = horarioDia.horaFin;
      refrigerio = horarioDia.refrigerioMinutos;
      mod = horarioDia.modalidad;
      activo = horarioDia.activo;
    }

    final computables = TimeCalculator.calcularHorasNetas(inicio, fin, refrigerio);

    state = RegistroFormState(
      id: const Uuid().v4(),
      fecha: fecha,
      horaInicio: inicio,
      horaFin: fin,
      descuentoAlmuerzoMinutos: refrigerio,
      modalidad: mod,
      actividades: '',
      horasComputables: computables,
      isEditing: false,
      isDiaConfiguradoActivo: activo,
    );
  }

  void cargarParaEdicion(RegistroHora registro) {
    state = RegistroFormState(
      id: registro.id,
      fecha: registro.fecha,
      horaInicio: registro.horaInicio,
      horaFin: registro.horaFin,
      descuentoAlmuerzoMinutos: registro.descuentoAlmuerzoMinutos,
      modalidad: registro.modalidad,
      actividades: registro.actividades,
      horasComputables: registro.horasComputables,
      isEditing: true,
      isDiaConfiguradoActivo: true,
    );
  }

  void setFecha(DateTime nuevaFecha) {
    if (!state.isEditing) {
      inicializarConFecha(nuevaFecha);
    } else {
      state = state.copyWith(fecha: nuevaFecha);
    }
  }

  void setHoraInicio(String inicio) {
    final computables = TimeCalculator.calcularHorasNetas(
      inicio,
      state.horaFin,
      state.descuentoAlmuerzoMinutos,
    );
    state = state.copyWith(
      horaInicio: inicio,
      horasComputables: computables,
    );
  }

  void setHoraFin(String fin) {
    final computables = TimeCalculator.calcularHorasNetas(
      state.horaInicio,
      fin,
      state.descuentoAlmuerzoMinutos,
    );
    state = state.copyWith(
      horaFin: fin,
      horasComputables: computables,
    );
  }

  void setDescuentoMinutos(int minutos) {
    final computables = TimeCalculator.calcularHorasNetas(
      state.horaInicio,
      state.horaFin,
      minutos,
    );
    state = state.copyWith(
      descuentoAlmuerzoMinutos: minutos,
      horasComputables: computables,
    );
  }

  void setModalidad(String modalidad) {
    state = state.copyWith(modalidad: modalidad);
  }

  void setActividades(String actividades) {
    state = state.copyWith(actividades: actividades);
  }

  RegistroHora toEntity() {
    return RegistroHora(
      id: state.id ?? const Uuid().v4(),
      fecha: state.fecha,
      horaInicio: state.horaInicio,
      horaFin: state.horaFin,
      descuentoAlmuerzoMinutos: state.descuentoAlmuerzoMinutos,
      horasComputables: state.horasComputables,
      modalidad: state.modalidad,
      actividades: state.actividades.trim(),
      createdAt: DateTime.now(),
    );
  }
}

final registroFormNotifierProvider =
    StateNotifierProvider<RegistroFormNotifier, RegistroFormState>((ref) {
  return RegistroFormNotifier(ref);
});

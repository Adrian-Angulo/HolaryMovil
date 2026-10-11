import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/horario_dia.dart';
import '../../domain/entities/perfil.dart';

enum HorarioPresetType {
  matutino,
  vespertino,
  completa,
  personalizado,
}

class OnboardingWizardState {
  final int currentStep;
  final String nombre;
  final double metaHorasTotal;
  final double? horasMinimasSemanalesPersonalizadas;
  final bool yaInicioHoras;
  final double horasInicialesPrevias;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool fechaFinEsManual;
  final HorarioPresetType presetType;
  final Map<String, HorarioDia> horarioSemanal;
  final bool isSubmitting;
  final String? errorMessage;

  const OnboardingWizardState({
    required this.currentStep,
    required this.nombre,
    required this.metaHorasTotal,
    this.horasMinimasSemanalesPersonalizadas,
    required this.yaInicioHoras,
    required this.horasInicialesPrevias,
    required this.fechaInicio,
    required this.fechaFin,
    this.fechaFinEsManual = false,
    required this.presetType,
    required this.horarioSemanal,
    this.isSubmitting = false,
    this.errorMessage,
  });

  /// Horas efectivas semanales sumando los días activos del horario
  double get horasSemanalesDelHorario {
    double total = 0.0;
    horarioSemanal.forEach((_, dia) {
      if (dia.activo) {
        total += dia.horasEfectivas;
      }
    });
    return total > 0 ? total : 20.0;
  }

  /// Ritmo semanal a usar para proyectar:
  /// Si el usuario ingresó un mínimo semanal personalizado, se usa ese; si no, las horas del horario.
  double get ritmoSemanalProyeccion {
    if (horasMinimasSemanalesPersonalizadas != null &&
        horasMinimasSemanalesPersonalizadas! > 0) {
      return horasMinimasSemanalesPersonalizadas!;
    }
    return horasSemanalesDelHorario;
  }

  /// ¿La proyección está usando el mínimo manual o el horario?
  bool get usaMinimoPersonalizado =>
      horasMinimasSemanalesPersonalizadas != null &&
      horasMinimasSemanalesPersonalizadas! > 0;

  int get semanasEstimadas {
    final horasRestantes = metaHorasTotal - horasInicialesPrevias;
    if (horasRestantes <= 0) return 0;
    final ritmo = ritmoSemanalProyeccion;
    if (ritmo <= 0) return 0;
    return (horasRestantes / ritmo).ceil();
  }

  /// Fecha estimada en que terminaría según el ritmo proyectado
  DateTime get fechaProyectadaEstimada {
    final semanas = semanasEstimadas;
    if (semanas <= 0) return fechaInicio;
    return fechaInicio.add(Duration(days: semanas * 7));
  }

  OnboardingWizardState copyWith({
    int? currentStep,
    String? nombre,
    double? metaHorasTotal,
    double? horasMinimasSemanalesPersonalizadas,
    bool clearHorasMinimas = false,
    bool? yaInicioHoras,
    double? horasInicialesPrevias,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    bool? fechaFinEsManual,
    HorarioPresetType? presetType,
    Map<String, HorarioDia>? horarioSemanal,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return OnboardingWizardState(
      currentStep: currentStep ?? this.currentStep,
      nombre: nombre ?? this.nombre,
      metaHorasTotal: metaHorasTotal ?? this.metaHorasTotal,
      horasMinimasSemanalesPersonalizadas: clearHorasMinimas
          ? null
          : (horasMinimasSemanalesPersonalizadas ??
              this.horasMinimasSemanalesPersonalizadas),
      yaInicioHoras: yaInicioHoras ?? this.yaInicioHoras,
      horasInicialesPrevias: horasInicialesPrevias ?? this.horasInicialesPrevias,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      fechaFinEsManual: fechaFinEsManual ?? this.fechaFinEsManual,
      presetType: presetType ?? this.presetType,
      horarioSemanal: horarioSemanal ?? this.horarioSemanal,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  factory OnboardingWizardState.initial({String nombre = 'Practicante'}) {
    final now = DateTime.now();
    final inicio = DateTime(now.year, now.month, now.day);
    // 360h a 20h/sem = 18 semanas por defecto
    final fin = inicio.add(const Duration(days: 18 * 7));

    return OnboardingWizardState(
      currentStep: 0,
      nombre: nombre.isEmpty ? 'Practicante' : nombre,
      metaHorasTotal: 360.0,
      horasMinimasSemanalesPersonalizadas: null,
      yaInicioHoras: false,
      horasInicialesPrevias: 0.0,
      fechaInicio: inicio,
      fechaFin: fin,
      fechaFinEsManual: false,
      presetType: HorarioPresetType.matutino,
      horarioSemanal: _generarHorarioPreset(HorarioPresetType.matutino),
    );
  }

  static Map<String, HorarioDia> _generarHorarioPreset(HorarioPresetType preset) {
    const dias = ['lunes', 'martes', 'miercoles', 'jueves', 'viernes', 'sabado', 'domingo'];
    final map = <String, HorarioDia>{};

    for (final dia in dias) {
      final esFinde = dia == 'sabado' || dia == 'domingo';
      if (esFinde) {
        map[dia] = HorarioDia(
          diaSemana: dia,
          activo: false,
          horaInicio: '08:00',
          horaFin: '12:00',
          refrigerioMinutos: 0,
          modalidad: 'Presencial',
        );
      } else {
        switch (preset) {
          // 4 horas: 08:00 AM a 12:00 PM (20h/semana)
          case HorarioPresetType.matutino:
            map[dia] = HorarioDia(
              diaSemana: dia,
              activo: true,
              horaInicio: '08:00',
              horaFin: '12:00',
              refrigerioMinutos: 0,
              modalidad: 'Presencial',
            );
            break;
          // 4 horas: 02:00 PM a 06:00 PM (14:00 - 18:00) (20h/semana)
          case HorarioPresetType.vespertino:
            map[dia] = HorarioDia(
              diaSemana: dia,
              activo: true,
              horaInicio: '14:00',
              horaFin: '18:00',
              refrigerioMinutos: 0,
              modalidad: 'Presencial',
            );
            break;
          // 08:00 AM a 06:00 PM (18:00) con 2 horas de refrigerio (120 min de 12 a 2) = 8h netas/día (40h/semana)
          case HorarioPresetType.completa:
            map[dia] = HorarioDia(
              diaSemana: dia,
              activo: true,
              horaInicio: '08:00',
              horaFin: '18:00',
              refrigerioMinutos: 120,
              modalidad: 'Presencial',
            );
            break;
          case HorarioPresetType.personalizado:
            map[dia] = HorarioDia(
              diaSemana: dia,
              activo: true,
              horaInicio: '08:00',
              horaFin: '12:00',
              refrigerioMinutos: 0,
              modalidad: 'Presencial',
            );
            break;
        }
      }
    }
    return map;
  }
}

class OnboardingWizardNotifier extends StateNotifier<OnboardingWizardState> {
  OnboardingWizardNotifier({String initialName = 'Practicante'})
      : super(OnboardingWizardState.initial(nombre: initialName));

  void setStep(int step) {
    if (step >= 0 && step <= 2) {
      state = state.copyWith(currentStep: step);
    }
  }

  void nextStep() {
    if (state.currentStep < 2) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void prevStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setNombre(String nombre) {
    state = state.copyWith(nombre: nombre);
  }

  void setMetaHoras(double meta) {
    state = state.copyWith(metaHorasTotal: meta);
    _recalcularFechaFin();
  }

  void setHorasMinimasSemanales(double? horas) {
    if (horas == null || horas <= 0) {
      state = state.copyWith(clearHorasMinimas: true);
    } else {
      state = state.copyWith(horasMinimasSemanalesPersonalizadas: horas);
    }
    _recalcularFechaFin();
  }

  void setYaInicioHoras(bool yaInicio) {
    state = state.copyWith(
      yaInicioHoras: yaInicio,
      horasInicialesPrevias: yaInicio ? state.horasInicialesPrevias : 0.0,
    );
    _recalcularFechaFin();
  }

  void setHorasPrevias(double horas) {
    state = state.copyWith(horasInicialesPrevias: horas);
    _recalcularFechaFin();
  }

  void setFechaInicio(DateTime inicio) {
    state = state.copyWith(fechaInicio: inicio);
    _recalcularFechaFin();
  }

  void setFechaFin(DateTime fin) {
    state = state.copyWith(
      fechaFin: fin,
      fechaFinEsManual: true,
    );
  }

  void aplicarPreset(HorarioPresetType preset) {
    state = state.copyWith(
      presetType: preset,
      horarioSemanal: OnboardingWizardState._generarHorarioPreset(preset),
    );
    _recalcularFechaFin();
  }

  void actualizarDia(String diaKey, HorarioDia dia) {
    final map = Map<String, HorarioDia>.from(state.horarioSemanal);
    map[diaKey] = dia;
    state = state.copyWith(
      horarioSemanal: map,
      presetType: HorarioPresetType.personalizado,
    );
    _recalcularFechaFin();
  }

  void _recalcularFechaFin() {
    // Si el usuario ya estableció manualmente una fecha fin de convenio, NO sobreescribirla
    if (state.fechaFinEsManual) return;

    final semanas = state.semanasEstimadas;
    if (semanas > 0) {
      final diasTotales = semanas * 7;
      final finEstimado = state.fechaInicio.add(Duration(days: diasTotales));
      state = state.copyWith(fechaFin: finEstimado);
    }
  }

  Perfil buildPerfilFinal() {
    final horasMinimasFinal = state.horasMinimasSemanalesPersonalizadas != null &&
            state.horasMinimasSemanalesPersonalizadas! > 0
        ? state.horasMinimasSemanalesPersonalizadas!
        : state.horasSemanalesDelHorario;

    return Perfil(
      nombre: state.nombre.trim().isEmpty ? 'Practicante' : state.nombre.trim(),
      metaHorasTotal: state.metaHorasTotal,
      horasInicialesPrevias: state.horasInicialesPrevias,
      horasMinimasSemanales: horasMinimasFinal,
      fechaInicio: state.fechaInicio,
      fechaFin: state.fechaFin,
      horarioSemanal: state.horarioSemanal,
      perfilCompletado: true,
    );
  }
}

final onboardingWizardProvider = StateNotifierProvider.autoDispose<
    OnboardingWizardNotifier, OnboardingWizardState>((ref) {
  return OnboardingWizardNotifier();
});

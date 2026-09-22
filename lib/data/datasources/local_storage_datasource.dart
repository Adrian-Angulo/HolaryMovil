import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../models/horario_dia_hive_model.dart';
import '../models/perfil_hive_model.dart';
import '../models/registro_hora_hive_model.dart';

class LocalStorageDataSource {
  static Future<void> init() async {
    await Hive.initFlutter();

    // Registrar adaptadores generados
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(RegistroHoraHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HorarioDiaHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PerfilHiveModelAdapter());
    }

    // Abrir cajas tipadas
    await Hive.openBox<RegistroHoraHiveModel>(AppConstants.registrosBoxName);
    await Hive.openBox<PerfilHiveModel>(AppConstants.perfilBoxName);
  }

  Box<RegistroHoraHiveModel> get _registrosBox =>
      Hive.box<RegistroHoraHiveModel>(AppConstants.registrosBoxName);

  Box<PerfilHiveModel> get _perfilBox =>
      Hive.box<PerfilHiveModel>(AppConstants.perfilBoxName);

  // --- Operaciones de Registros ---
  List<RegistroHoraHiveModel> getAllRegistros() {
    return _registrosBox.values.toList()
      ..sort((a, b) => b.fecha.compareTo(a.fecha));
  }

  RegistroHoraHiveModel? getRegistroById(String id) {
    return _registrosBox.get(id);
  }

  Future<void> saveRegistro(RegistroHoraHiveModel registro) async {
    await _registrosBox.put(registro.id, registro);
  }

  Future<void> deleteRegistro(String id) async {
    await _registrosBox.delete(id);
  }

  // --- Operaciones de Perfil ---
  PerfilHiveModel getPerfil() {
    final perfil = _perfilBox.get(AppConstants.perfilKey);
    if (perfil != null) {
      return perfil;
    }

    // Perfil por defecto
    final defaultPerfil = PerfilHiveModel(
      nombre: 'Practicante',
      metaHorasTotal: 360.0,
      fechaInicio: DateTime.now(),
      fechaFin: DateTime.now().add(const Duration(days: 90)),
      horarioSemanal: {
        'lunes': HorarioDiaHiveModel(
          diaSemana: 'lunes',
          activo: true,
          horaInicio: '08:00',
          horaFin: '13:00',
          refrigerioMinutos: 0,
          modalidad: 'Presencial',
        ),
        'martes': HorarioDiaHiveModel(
          diaSemana: 'martes',
          activo: true,
          horaInicio: '14:00',
          horaFin: '19:00',
          refrigerioMinutos: 0,
          modalidad: 'Presencial',
        ),
        'miercoles': HorarioDiaHiveModel(
          diaSemana: 'miercoles',
          activo: true,
          horaInicio: '14:00',
          horaFin: '19:00',
          refrigerioMinutos: 0,
          modalidad: 'Presencial',
        ),
        'jueves': HorarioDiaHiveModel(
          diaSemana: 'jueves',
          activo: true,
          horaInicio: '08:00',
          horaFin: '13:00',
          refrigerioMinutos: 0,
          modalidad: 'Presencial',
        ),
        'viernes': HorarioDiaHiveModel(
          diaSemana: 'viernes',
          activo: true,
          horaInicio: '08:00',
          horaFin: '13:00',
          refrigerioMinutos: 0,
          modalidad: 'Presencial',
        ),
        'sabado': HorarioDiaHiveModel(
          diaSemana: 'sabado',
          activo: false,
          horaInicio: '08:00',
          horaFin: '13:00',
          refrigerioMinutos: 0,
          modalidad: 'Presencial',
        ),
        'domingo': HorarioDiaHiveModel(
          diaSemana: 'domingo',
          activo: false,
          horaInicio: '08:00',
          horaFin: '13:00',
          refrigerioMinutos: 0,
          modalidad: 'Presencial',
        ),
      },
    );

    _perfilBox.put(AppConstants.perfilKey, defaultPerfil);
    return defaultPerfil;
  }

  Future<void> savePerfil(PerfilHiveModel perfil) async {
    await _perfilBox.put(AppConstants.perfilKey, perfil);
  }
}

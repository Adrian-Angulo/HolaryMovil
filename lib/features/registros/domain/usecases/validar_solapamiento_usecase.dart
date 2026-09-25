import '../../../../core/utils/time_calculator.dart';
import '../entities/registro_hora.dart';

class ValidarSolapamientoUseCase {
  /// Retorna el registro con el que existe conflicto de solapamiento de horario,
  /// o `null` si el horario está completamente libre.
  RegistroHora? execute({
    required RegistroHora registro,
    required List<RegistroHora> registrosExistentes,
  }) {
    for (final existente in registrosExistentes) {
      // Ignorar el mismo registro si estamos editando
      if (existente.id == registro.id) continue;

      // Verificar si es exactamente la misma fecha (año, mes, día)
      final mismaFecha = existente.fecha.year == registro.fecha.year &&
          existente.fecha.month == registro.fecha.month &&
          existente.fecha.day == registro.fecha.day;

      if (mismaFecha) {
        final solapa = TimeCalculator.haySolapamiento(
          registro.horaInicio,
          registro.horaFin,
          existente.horaInicio,
          existente.horaFin,
        );

        if (solapa) {
          return existente;
        }
      }
    }
    return null;
  }
}

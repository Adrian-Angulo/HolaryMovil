import 'package:flutter_test/flutter_test.dart';
import 'package:practi_horas_app/core/utils/time_calculator.dart';

void main() {
  group('TimeCalculator Tests', () {
    test('Calcula 5 horas exactas sin refrigerio (08:00 a 13:00)', () {
      final horas = TimeCalculator.calcularHorasNetas('08:00', '13:00', 0);
      expect(horas, 5.0);
    });

    test('Calcula 8 horas con 60 minutos de descuento (08:00 a 17:00 con 60m almuerzo)', () {
      final horas = TimeCalculator.calcularHorasNetas('08:00', '17:00', 60);
      expect(horas, 8.0);
    });

    test('Calcula horas fraccionadas correctamente (08:00 a 13:30 con 30m refrigerio = 5.0h)', () {
      final horas = TimeCalculator.calcularHorasNetas('08:00', '13:30', 30);
      expect(horas, 5.0);
    });

    test('Retorna 0.0 si el rango es negativo o fin es menor que inicio', () {
      final horas = TimeCalculator.calcularHorasNetas('14:00', '08:00', 0);
      expect(horas, 0.0);
    });

    test('Formatea horas a texto legible', () {
      expect(TimeCalculator.formatHorasHumanReadable(5.5), '5h 30m');
      expect(TimeCalculator.formatHorasHumanReadable(5.0), '5 h');
      expect(TimeCalculator.formatHorasHumanReadable(0.0), '0 hrs');
    });
  });
}

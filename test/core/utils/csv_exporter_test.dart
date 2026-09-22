import 'package:flutter_test/flutter_test.dart';
import 'package:practi_horas_app/core/utils/csv_exporter.dart';
import 'package:practi_horas_app/domain/entities/registro_hora.dart';

void main() {
  group('CsvExporter Tests', () {
    test('Genera encabezados y contenido CSV en el formato exacto requerido', () {
      final registros = [
        RegistroHora(
          id: '1',
          fecha: DateTime(2026, 9, 21),
          horaInicio: '08:00',
          horaFin: '13:00',
          descuentoAlmuerzoMinutos: 0,
          horasComputables: 5.0,
          modalidad: 'Presencial',
          actividades: 'Desarrollo de módulos',
          createdAt: DateTime.now(),
        ),
        RegistroHora(
          id: '2',
          fecha: DateTime(2026, 9, 22),
          horaInicio: '08:00',
          horaFin: '14:00',
          descuentoAlmuerzoMinutos: 60,
          horasComputables: 5.0,
          modalidad: 'Remoto',
          actividades: 'Revisión y pruebas',
          createdAt: DateTime.now(),
        ),
      ];

      final csv = CsvExporter.generarCsvString(
        registros: registros,
        horasInicialesPrevias: 10.0,
      );

      // Debe incluir UTF-8 BOM
      expect(csv.startsWith('\uFEFF'), true);

      // Debe incluir encabezados exactos
      expect(
        csv.contains('Fecha,Hora de inicio,Hora de Fin,Resumen actividades realizada,Horas realizadas,Horas totales Sumatoria (∑)'),
        true,
      );

      // Debe incluir fila inicial de horas previas
      expect(csv.contains('10.00'), true);

      // Primera jornada acumulada: 10 + 5 = 15.00
      expect(csv.contains('08:00,13:00,"Desarrollo de módulos",5.00,15.00'), true);

      // Segunda jornada acumulada: 15 + 5 = 20.00
      expect(csv.contains('08:00,14:00,"Revisión y pruebas",5.00,20.00'), true);
    });
  });
}

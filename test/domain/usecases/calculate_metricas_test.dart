import 'package:flutter_test/flutter_test.dart';
import 'package:practi_horas_app/domain/entities/perfil.dart';
import 'package:practi_horas_app/domain/entities/registro_hora.dart';
import 'package:practi_horas_app/domain/usecases/estadisticas/calculate_metricas_usecase.dart';

void main() {
  group('CalculateMetricasUseCase Tests', () {
    final useCase = CalculateMetricasUseCase();
    final perfil = Perfil.defaultPerfil().copyWith(metaHorasTotal: 100.0);

    test('Calcula métricas iniciales con lista vacía de registros', () {
      final metricas = useCase.execute(
        registros: [],
        perfil: perfil,
        fechaReferencia: DateTime(2026, 9, 21), // Lunes
      );

      expect(metricas.horasTotalesCompletadas, 0.0);
      expect(metricas.metaHorasTotal, 100.0);
      expect(metricas.horasRestantes, 100.0);
      expect(metricas.porcentajeProgreso, 0.0);
      expect(metricas.totalDiasTrabajados, 0);
    });

    test('Calcula métricas correctamente con registros agregados', () {
      final fechaRef = DateTime(2026, 9, 21); // Lunes
      final registros = [
        RegistroHora(
          id: '1',
          fecha: DateTime(2026, 9, 21), // Lunes de esta semana
          horaInicio: '08:00',
          horaFin: '13:00',
          descuentoAlmuerzoMinutos: 0,
          horasComputables: 5.0,
          modalidad: 'Presencial',
          actividades: 'Desarrollo',
          createdAt: DateTime.now(),
        ),
        RegistroHora(
          id: '2',
          fecha: DateTime(2026, 9, 22), // Martes de esta semana
          horaInicio: '14:00',
          horaFin: '19:00',
          descuentoAlmuerzoMinutos: 0,
          horasComputables: 5.0,
          modalidad: 'Presencial',
          actividades: 'Testing',
          createdAt: DateTime.now(),
        ),
      ];

      final metricas = useCase.execute(
        registros: registros,
        perfil: perfil,
        fechaReferencia: fechaRef,
      );

      expect(metricas.horasTotalesCompletadas, 10.0);
      expect(metricas.metaHorasTotal, 100.0);
      expect(metricas.horasRestantes, 90.0);
      expect(metricas.porcentajeProgreso, 10.0);
      expect(metricas.horasEstaSemana, 10.0);
      expect(metricas.totalDiasTrabajados, 2);
      expect(metricas.promedioHorasPorDia, 5.0);
      expect(metricas.horasPorDiaSemana[1], 5.0); // Lunes
      expect(metricas.horasPorDiaSemana[2], 5.0); // Martes
      expect(metricas.horasPorDiaSemana[3], 0.0); // Miércoles
    });
  });
}

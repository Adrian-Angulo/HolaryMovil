import 'package:flutter_test/flutter_test.dart';
import 'package:practi_horas_app/features/dashboard/domain/entities/metricas_dashboard.dart';
import 'package:practi_horas_app/features/dashboard/domain/usecases/calculate_metricas_usecase.dart';
import 'package:practi_horas_app/features/perfil/domain/entities/perfil.dart';
import 'package:practi_horas_app/features/registros/domain/entities/registro_hora.dart';

void main() {
  group('CalculateMetricasUseCase Tests', () {
    final useCase = CalculateMetricasUseCase();
    final perfil = Perfil.defaultPerfil().copyWith(
      metaHorasTotal: 100.0,
      horasInicialesPrevias: 20.0,
      fechaInicio: DateTime(2026, 9, 1),
      fechaFin: DateTime(2026, 9, 30),
    );

    test('Calcula métricas iniciales considerando horas iniciales cursadas', () {
      final metricas = useCase.execute(
        registros: [],
        perfil: perfil,
        fechaReferencia: DateTime(2026, 9, 1),
      );

      expect(metricas.horasTotalesCompletadas, 20.0);
      expect(metricas.horasPreviasCursadas, 20.0);
      expect(metricas.metaHorasTotal, 100.0);
      expect(metricas.horasRestantes, 80.0);
      expect(metricas.porcentajeProgreso, 20.0);
      expect(metricas.totalDiasTrabajados, 0);
    });

    test('Calcula ritmo y cumplimiento correctamente', () {
      final fechaRef = DateTime(2026, 9, 21); // Lunes
      final registros = [
        RegistroHora(
          id: '1',
          fecha: DateTime(2026, 9, 21),
          horaInicio: '08:00',
          horaFin: '13:00',
          descuentoAlmuerzoMinutos: 0,
          horasComputables: 5.0,
          modalidad: 'Presencial',
          actividades: 'Desarrollo',
          createdAt: DateTime.now(),
        ),
      ];

      final metricas = useCase.execute(
        registros: registros,
        perfil: perfil,
        fechaReferencia: fechaRef,
      );

      // Total = 20 (previas) + 5 (registradas) = 25.0
      expect(metricas.horasTotalesCompletadas, 25.0);
      expect(metricas.horasRegistradasEnApp, 5.0);
      expect(metricas.metaHorasTotal, 100.0);
      expect(metricas.horasRestantes, 75.0);
      expect(metricas.porcentajeProgreso, 25.0);
      expect(metricas.totalDiasTrabajados, 1);
      expect(metricas.estadoRitmo != EstadoRitmo.sinFechas, true);
      expect(metricas.ritmoDiarioSugerido > 0, true);
    });
  });
}

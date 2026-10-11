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

    test('Calcula métricas iniciales al inicio del periodo sin sesgo matutino', () {
      final perfilSinHoras = perfil.copyWith(horasInicialesPrevias: 0.0);
      final metricas = useCase.execute(
        registros: [],
        perfil: perfilSinHoras,
        fechaReferencia: DateTime(2026, 9, 1), // Primer día del periodo
      );

      expect(metricas.horasTotalesCompletadas, 0.0);
      expect(metricas.horasPreviasCursadas, 0.0);
      expect(metricas.metaHorasTotal, 100.0);
      expect(metricas.horasRestantes, 100.0);
      expect(metricas.porcentajeProgreso, 0.0);
      expect(metricas.totalDiasTrabajados, 0);
      // Al ser el inicio de hoy, no hay días cerrados previos, no se exige horas antes de trabajarlas
      expect(metricas.horasEsperadasHoy, 0.0);
      expect(metricas.diferenciaHorasRitmo, 0.0);
      expect(metricas.estadoRitmo, EstadoRitmo.aTiempo);
    });

    test('Calcula ritmo y cumplimiento correctamente durante el periodo', () {
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
          createdAt: DateTime(2026, 9, 21),
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

    test('Retorna EstadoRitmo.vencido cuando la fecha actual sobrepasa fechaFin y restan horas', () {
      final fechaPasada = DateTime(2026, 10, 5); // Fecha posterior al 30 de septiembre

      final metricas = useCase.execute(
        registros: [],
        perfil: perfil,
        fechaReferencia: fechaPasada,
      );

      expect(metricas.horasRestantes, 80.0);
      expect(metricas.diasHabilesRestantes, 0);
      expect(metricas.estadoRitmo, EstadoRitmo.vencido);
      expect(metricas.ritmoDiarioSugerido, 0.0);
      expect(metricas.mensajeRitmo.contains('finalizó'), true);
    });

    test('Informa correctamente cuando el periodo no ha iniciado', () {
      final fechaFutura = DateTime(2026, 8, 15); // Antes del 1 de septiembre

      final metricas = useCase.execute(
        registros: [],
        perfil: perfil,
        fechaReferencia: fechaFutura,
      );

      expect(metricas.estadoRitmo, EstadoRitmo.aTiempo);
      expect(metricas.mensajeRitmo.contains('inicia el 2026-09-01'), true);
      expect(metricas.diasHabilesRestantes > 0, true);
    });

    test('Mantiene estabilidad intra-día sin disparar falso adelantado tras registrar hoy', () {
      final perfilUniforme = perfil.copyWith(
        horasInicialesPrevias: 0.0,
        metaHorasTotal: 100.0,
        fechaInicio: DateTime(2026, 9, 1), // Martes
        fechaFin: DateTime(2026, 9, 28),   // 20 días hábiles -> 5h/día
      );

      final registroHoy = [
        RegistroHora(
          id: 'reg-hoy',
          fecha: DateTime(2026, 9, 1),
          horaInicio: '08:00',
          horaFin: '13:00',
          descuentoAlmuerzoMinutos: 0,
          horasComputables: 5.0,
          modalidad: 'Presencial',
          actividades: 'Desarrollo normal',
          createdAt: DateTime(2026, 9, 1),
        ),
      ];

      final metricas = useCase.execute(
        registros: registroHoy,
        perfil: perfilUniforme,
        fechaReferencia: DateTime(2026, 9, 1), // Mismo día tras registrar
      );

      expect(metricas.estadoRitmo, EstadoRitmo.aTiempo);
      expect(metricas.diferenciaHorasRitmo, 0.0);
      expect(metricas.diasHabilesRestantes, 19);
      expect(metricas.ritmoDiarioSugerido, 5.0);
    });

    test('Alerta sobrecarga de jornada permitida cuando el ritmo necesario supera 6h/día', () {
      final perfilCorto = perfil.copyWith(
        horasInicialesPrevias: 0.0,
        metaHorasTotal: 100.0,
        fechaInicio: DateTime(2026, 9, 1),
        fechaFin: DateTime(2026, 9, 14), // 10 días hábiles
      );

      // Día 5 sin ningún registro
      final metricas = useCase.execute(
        registros: [],
        perfil: perfilCorto,
        fechaReferencia: DateTime(2026, 9, 7),
      );

      expect(metricas.estadoRitmo, EstadoRitmo.atrasado);
      expect(metricas.ritmoDiarioSugerido > 6.0, true);
      expect(metricas.mensajeRitmo.contains('excede la jornada habitual'), true);
    });
  });
}

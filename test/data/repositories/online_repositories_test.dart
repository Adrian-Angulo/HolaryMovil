import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:practi_horas_app/core/errors/failures.dart';
import 'package:practi_horas_app/core/network/api_exceptions.dart';
import 'package:practi_horas_app/core/storage/session_storage.dart';
import 'package:practi_horas_app/features/perfil/data/datasources/perfil_remote_datasource.dart';
import 'package:practi_horas_app/features/perfil/data/models/perfil_api_model.dart';
import 'package:practi_horas_app/features/perfil/data/repositories/perfil_repository_impl.dart';
import 'package:practi_horas_app/features/perfil/domain/entities/perfil.dart';
import 'package:practi_horas_app/features/registros/data/datasources/registro_remote_datasource.dart';
import 'package:practi_horas_app/features/registros/data/models/registro_hora_api_model.dart';
import 'package:practi_horas_app/features/registros/data/repositories/registro_repository_impl.dart';
import 'package:practi_horas_app/features/registros/domain/entities/registro_hora.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeFailingRegistroRemoteDataSource implements IRegistroRemoteDataSource {
  @override
  Future<List<RegistroHoraApiModel>> getRegistros({
    int? mes,
    int? anio,
    String? modalidad,
    String? desde,
    String? hasta,
  }) async {
    throw NetworkException(message: 'Sin conexión');
  }

  @override
  Future<RegistroHoraApiModel> createRegistro(RegistroHoraApiModel model) async {
    throw const SocketException('No route to host');
  }

  @override
  Future<RegistroHoraApiModel> updateRegistro(RegistroHoraApiModel model) async {
    throw NetworkException(message: 'Timeout');
  }

  @override
  Future<void> deleteRegistro(String id) async {
    throw NetworkException(message: 'Offline');
  }
}

class _FakeFailingPerfilRemoteDataSource implements IPerfilRemoteDataSource {
  @override
  Future<PerfilApiModel> getProfile() async {
    throw NetworkException(message: 'Fallo al conectar');
  }

  @override
  Future<PerfilApiModel> updateProfile(PerfilApiModel model) async {
    throw TimeoutException('Petición expiró');
  }
}

void main() {
  late SessionStorage sessionStorage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sessionStorage = await SessionStorage.create();
  });

  group('Online-First Repositories Tests', () {
    test('RegistroRepositoryImpl.getRegistros() propaga Left(NetworkFailure) sin fallback offline', () async {
      final repository = RegistroRepositoryImpl(_FakeFailingRegistroRemoteDataSource());

      final result = await repository.getRegistros();

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('No debería retornar datos cuando la red falla'),
      );
    });

    test('RegistroRepositoryImpl.saveRegistro() propaga Left(NetworkFailure) en vez de falso éxito', () async {
      final repository = RegistroRepositoryImpl(_FakeFailingRegistroRemoteDataSource());

      final dummyRegistro = RegistroHora(
        id: '123',
        fecha: DateTime(2026, 10, 6),
        horaInicio: '09:00',
        horaFin: '17:00',
        descuentoAlmuerzoMinutos: 60,
        horasComputables: 7.0,
        modalidad: 'Presencial',
        actividades: 'Desarrollo',
        createdAt: DateTime(2026, 10, 6),
      );

      final result = await repository.saveRegistro(dummyRegistro);

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('No debería simular guardado offline'),
      );
    });

    test('PerfilRepositoryImpl.getPerfil() propaga Left(NetworkFailure) sin inventar perfil por defecto', () async {
      final repository = PerfilRepositoryImpl(_FakeFailingPerfilRemoteDataSource(), sessionStorage);

      final result = await repository.getPerfil();

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('No debería retornar perfil por defecto si la red falla'),
      );
    });

    test('PerfilRepositoryImpl.savePerfil() propaga Left(NetworkFailure) ante Timeout', () async {
      final repository = PerfilRepositoryImpl(_FakeFailingPerfilRemoteDataSource(), sessionStorage);

      final result = await repository.savePerfil(Perfil.defaultPerfil());

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('No debería fingir guardado si el servidor no respondió'),
      );
    });
  });
}

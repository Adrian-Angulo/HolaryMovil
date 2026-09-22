import '../entities/registro_hora.dart';

abstract class IRegistroRepository {
  Future<List<RegistroHora>> getRegistros();
  Future<RegistroHora?> getRegistroById(String id);
  Future<void> saveRegistro(RegistroHora registro);
  Future<void> updateRegistro(RegistroHora registro);
  Future<void> deleteRegistro(String id);
  Future<List<RegistroHora>> getRegistrosByRangoFecha(DateTime inicio, DateTime fin);
}

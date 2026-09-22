import '../entities/perfil.dart';

abstract class IPerfilRepository {
  Future<Perfil> getPerfil();
  Future<void> savePerfil(Perfil perfil);
}

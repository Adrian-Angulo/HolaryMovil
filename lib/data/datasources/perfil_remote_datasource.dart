import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../models/perfil_api_model.dart';

abstract class IPerfilRemoteDataSource {
  Future<PerfilApiModel> getProfile();
  Future<PerfilApiModel> updateProfile(PerfilApiModel perfil);
}

class PerfilRemoteDataSourceImpl implements IPerfilRemoteDataSource {
  final ApiClient _client;

  PerfilRemoteDataSourceImpl(this._client);

  @override
  Future<PerfilApiModel> getProfile() async {
    final response = await _client.get(AppConstants.profileEndpoint);
    return PerfilApiModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<PerfilApiModel> updateProfile(PerfilApiModel perfil) async {
    final response = await _client.put(
      AppConstants.profileEndpoint,
      body: perfil.toJson(),
    );
    return PerfilApiModel.fromJson(response as Map<String, dynamic>);
  }
}

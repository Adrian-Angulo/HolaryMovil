import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/registro_hora_api_model.dart';

abstract class IRegistroRemoteDataSource {
  Future<List<RegistroHoraApiModel>> getRegistros({
    int? mes,
    int? anio,
    String? modalidad,
    String? desde,
    String? hasta,
  });
  Future<RegistroHoraApiModel> createRegistro(RegistroHoraApiModel registro);
  Future<RegistroHoraApiModel> updateRegistro(RegistroHoraApiModel registro);
  Future<void> deleteRegistro(String id);
}

class RegistroRemoteDataSourceImpl implements IRegistroRemoteDataSource {
  final ApiClient _client;

  RegistroRemoteDataSourceImpl(this._client);

  @override
  Future<List<RegistroHoraApiModel>> getRegistros({
    int? mes,
    int? anio,
    String? modalidad,
    String? desde,
    String? hasta,
  }) async {
    final query = <String, dynamic>{
      if (mes != null) 'mes': mes,
      if (anio != null) 'anio': anio,
      if (modalidad != null && modalidad.isNotEmpty) 'modalidad': modalidad,
      if (desde != null) 'desde': desde,
      if (hasta != null) 'hasta': hasta,
    };

    final response = await _client.get(
      AppConstants.registrosEndpoint,
      queryParameters: query.isNotEmpty ? query : null,
    );

    final List<dynamic> list;
    if (response is List) {
      list = response;
    } else if (response is Map<String, dynamic> && response['data'] is List) {
      list = response['data'] as List;
    } else {
      list = [];
    }

    return list.map((item) => RegistroHoraApiModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  @override
  Future<RegistroHoraApiModel> createRegistro(RegistroHoraApiModel registro) async {
    final response = await _client.post(
      AppConstants.registrosEndpoint,
      body: registro.toJson(),
    );

    final map = response is Map<String, dynamic>
        ? (response['data'] is Map<String, dynamic> ? response['data'] as Map<String, dynamic> : response)
        : <String, dynamic>{};

    return RegistroHoraApiModel.fromJson(map);
  }

  @override
  Future<RegistroHoraApiModel> updateRegistro(RegistroHoraApiModel registro) async {
    final response = await _client.put(
      '${AppConstants.registrosEndpoint}/${registro.id}',
      body: registro.toJson(),
    );

    final map = response is Map<String, dynamic>
        ? (response['data'] is Map<String, dynamic> ? response['data'] as Map<String, dynamic> : response)
        : <String, dynamic>{};

    return RegistroHoraApiModel.fromJson(map);
  }

  @override
  Future<void> deleteRegistro(String id) async {
    await _client.delete('${AppConstants.registrosEndpoint}/$id');
  }
}

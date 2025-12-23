import 'dart:convert';
import 'package:joymodels_mobile/data/mapper/sso_mapper.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_user_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/response_types/sso_user_response_api_model.dart';
import 'package:joymodels_mobile/data/services/sso_service.dart';
import 'package:joymodels_mobile/domain/models/sso/request_types/sso_user_create_request.dart';
import 'package:joymodels_mobile/domain/models/sso/response_types/sso_user_response.dart';

class SsoRepository {
  final SsoService _service;

  SsoRepository(this._service);

  Future<SsoUserResponse> createUser(SsoUserCreateRequest domainModel) async {
    final SsoUserCreateRequestApiModel apiRequest = domainModel.toApiModel();

    final response = await _service.create(apiRequest);

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      final apiResponse = SsoUserResponseApiModel.fromJson(jsonMap);
      return apiResponse.toDomain();
    } else {
      throw Exception(
        'Failed to create user: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

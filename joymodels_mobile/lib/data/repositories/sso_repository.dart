import 'dart:convert';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_user_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/response_types/sso_user_response_api_model.dart';
import 'package:joymodels_mobile/data/services/sso_service.dart';

class SsoRepository {
  final SsoService _service;

  SsoRepository(this._service);

  Future<SsoUserResponseApiModel> createUser(
    SsoUserCreateRequestApiModel apiRequest,
  ) async {
    final response = await _service.create(apiRequest);

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return SsoUserResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to create user: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

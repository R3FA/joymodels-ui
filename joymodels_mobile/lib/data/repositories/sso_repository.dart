import 'dart:convert';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_new_otp_code_request_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_user_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_user_login_request_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/response_types/sso_login_response_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/response_types/sso_user_response_api_model.dart';
import 'package:joymodels_mobile/data/services/sso_service.dart';

class SsoRepository {
  final SsoService _service;

  SsoRepository(this._service);

  Future<SsoUserResponseApiModel> create(
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

  Future<bool> requestNewOtpCode(
    SsoNewOtpCodeRequestApiModel apiRequest,
  ) async {
    final response = await _service.requestNewOtpCode(apiRequest);

    if (response.statusCode == 201 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception(
        'Failed to send new otp code: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<SsoLoginResponse> login(SsoUserLoginRequestApiModel apiRequest) async {
    final response = await _service.login(apiRequest);

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return SsoLoginResponse.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to login user: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

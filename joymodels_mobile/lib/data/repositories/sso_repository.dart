import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/exceptions/network_exception.dart';
import 'package:joymodels_mobile/data/core/services/auth_service.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_logout_request_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_new_otp_code_request_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_password_change_request_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_user_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_user_login_request_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_verify_request_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/response_types/sso_login_response_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/response_types/sso_user_response_api_model.dart';
import 'package:joymodels_mobile/data/services/sso_service.dart';

class SsoRepository {
  final SsoService _service;
  final AuthService _authService;

  SsoRepository(this._service, this._authService);

  Future<SsoUserResponseApiModel> create(
    SsoUserCreateRequestApiModel request,
  ) async {
    final http.Response response;
    try {
      response = await _service.create(request);
    } on SocketException {
      throw NetworkException();
    }

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return SsoUserResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to create user: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<SsoUserResponseApiModel> verify(
    SsoVerifyRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.verify(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return SsoUserResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to verify user: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<bool> requestNewOtpCode(SsoNewOtpCodeRequestApiModel request) async {
    final response = await _authService.request(
      () => _service.requestNewOtpCode(request),
    );

    if (response.statusCode == 201 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception(
        'Failed to send new otp code: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<SsoLoginResponse> login(SsoUserLoginRequestApiModel request) async {
    final http.Response response;
    try {
      response = await _service.login(request);
    } on SocketException {
      throw NetworkException();
    }

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return SsoLoginResponse.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to login user: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> logout(SsoLogoutRequestApiModel request) async {
    final response = await _authService.request(() => _service.logout(request));

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to logout: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> requestPasswordChange(
    SsoPasswordChangeRequestApiModel request,
  ) async {
    final response = await _authService.request(
      () => _service.requestPasswordChange(request),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to change password: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

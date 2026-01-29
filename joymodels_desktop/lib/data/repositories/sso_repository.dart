import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:joymodels_desktop/data/core/exceptions/network_exception.dart';
import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_desktop/data/model/sso/request_types/sso_logout_request_api_model.dart';
import 'package:joymodels_desktop/data/model/sso/request_types/sso_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/sso/request_types/sso_set_role_request_api_model.dart';
import 'package:joymodels_desktop/data/model/sso/request_types/sso_user_login_request_api_model.dart';
import 'package:joymodels_desktop/data/model/sso/response_types/sso_login_response_api_model.dart';
import 'package:joymodels_desktop/data/model/sso/response_types/sso_user_response_api_model.dart';
import 'package:joymodels_desktop/data/services/sso_service.dart';

class SsoRepository {
  final SsoService _service;
  final AuthService _authService;

  SsoRepository(this._service, this._authService);

  Future<SsoLoginResponse> adminLogin(
    SsoUserLoginRequestApiModel request,
  ) async {
    final http.Response response;
    try {
      response = await _service.adminLogin(request);
    } on SocketException {
      throw NetworkException();
    }

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return SsoLoginResponse.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to login admin: ${response.statusCode} - ${response.body}',
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

  Future<PaginationResponseApiModel<SsoUserResponseApiModel>> search(
    SsoSearchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.search(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel<SsoUserResponseApiModel>.fromJson(
        jsonMap,
        (item) => SsoUserResponseApiModel.fromJson(item),
      );
    } else {
      throw Exception(
        'Failed to search users: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> setRole(SsoSetRoleRequestApiModel request) async {
    final response = await _authService.request(
      () => _service.setRole(request),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to set role: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> delete(String userUuid) async {
    final response = await _authService.request(
      () => _service.delete(userUuid),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete user: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

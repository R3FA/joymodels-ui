import 'dart:convert';
import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_desktop/data/model/user_role/request_types/user_role_create_request_api_model.dart';
import 'package:joymodels_desktop/data/model/user_role/request_types/user_role_patch_request_api_model.dart';
import 'package:joymodels_desktop/data/model/user_role/request_types/user_role_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/user_role/response_types/user_role_response_api_model.dart';
import 'package:joymodels_desktop/data/services/user_role_service.dart';

class UserRoleRepository {
  final UserRoleService _service;
  final AuthService _authService;

  UserRoleRepository(this._service, this._authService);

  Future<UserRoleResponseApiModel> getByUuid(String userRoleUuid) async {
    final response = await _authService.request(
      () => _service.getByUuid(userRoleUuid),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return UserRoleResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to fetch user role: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PaginationResponseApiModel<UserRoleResponseApiModel>> search(
    UserRoleSearchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.search(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel<UserRoleResponseApiModel>.fromJson(
        jsonMap,
        (item) => UserRoleResponseApiModel.fromJson(item),
      );
    } else {
      throw Exception(
        'Failed to search user roles: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<UserRoleResponseApiModel> create(
    UserRoleCreateRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.create(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return UserRoleResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to create user role: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<UserRoleResponseApiModel> patch(
    UserRolePatchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.patch(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return UserRoleResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to update user role: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> delete(String userRoleUuid) async {
    final response = await _authService.request(
      () => _service.delete(userRoleUuid),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete user role: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

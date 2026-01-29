import 'dart:convert';
import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_desktop/data/model/users/request_types/user_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/users/response_types/users_response_api_model.dart';
import 'package:joymodels_desktop/data/services/users_service.dart';

class UsersRepository {
  final UsersService _service;
  final AuthService _authService;

  UsersRepository(this._service, this._authService);

  Future<PaginationResponseApiModel<UsersResponseApiModel>> search(
    UsersSearchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.search(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel<UsersResponseApiModel>.fromJson(
        jsonMap,
        (item) => UsersResponseApiModel.fromJson(item),
      );
    } else {
      throw Exception(
        'Failed to fetch users: ${response.statusCode} - ${response.body}',
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

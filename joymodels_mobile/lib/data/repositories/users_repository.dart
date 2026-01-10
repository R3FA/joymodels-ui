import 'dart:convert';
import 'package:joymodels_mobile/data/core/services/auth_service.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/model/users/request_types/user_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/core/response_types/picture_response_api_model.dart';
import 'package:joymodels_mobile/data/model/users/response_types/users_response_api_model.dart';
import 'package:joymodels_mobile/data/services/users_service.dart';

class UsersRepository {
  final UsersService _service;
  final AuthService _authService;

  UsersRepository(this._service, this._authService);

  Future<UsersResponseApiModel> getByUuid(String userUuid) async {
    final response = await _authService.request(
      () => _service.getByUuid(userUuid),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return UsersResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to fetch user by its uuid: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PictureResponse> getUserAvatar(String userUuid) async {
    final response = await _authService.request(
      () => _service.getUserAvatar(userUuid),
    );

    if (response.statusCode == 200) {
      final contentType =
          response.headers['content-type'] ?? 'application/octet-stream';
      final fileBytes = response.bodyBytes;
      return PictureResponse(fileBytes: fileBytes, contentType: contentType);
    } else {
      throw Exception(
        'Failed to fetch user avatar by its uuid: ${response.statusCode} - ${response.body}',
      );
    }
  }

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
}

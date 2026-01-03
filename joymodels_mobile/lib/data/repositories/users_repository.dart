import 'dart:convert';
import 'package:joymodels_mobile/data/core/services/auth_service.dart';
import 'package:joymodels_mobile/data/model/users/response_types/users_avatar_response_api_model.dart';
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

  Future<UsersAvatarResponse> getUserAvatar(String userUuid) async {
    final response = await _authService.request(
      () => _service.getUserAvatar(userUuid),
    );

    if (response.statusCode == 200) {
      final contentType =
          response.headers['content-type'] ?? 'application/octet-stream';
      final fileBytes = response.bodyBytes;
      return UsersAvatarResponse(
        fileBytes: fileBytes,
        contentType: contentType,
      );
    } else {
      throw Exception(
        'Failed to fetch user avatar by its uuid: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

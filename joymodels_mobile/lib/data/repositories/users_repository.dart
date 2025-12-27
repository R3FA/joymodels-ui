import 'dart:convert';

import 'package:joymodels_mobile/data/model/users/request_types/users_response_api_model.dart';
import 'package:joymodels_mobile/data/services/users_service.dart';

class UsersRepository {
  final UsersService _service;

  UsersRepository(this._service);

  Future<UsersResponseApiModel> getByUuid(String userUuid) async {
    final response = await _service.getByUuid(userUuid);

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return UsersResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to fetch user by its uuid: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

import 'package:http/http.dart' as http;
import 'package:joymodels_desktop/data/core/config/api_constants.dart';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';
import 'package:joymodels_desktop/data/model/user_role/request_types/user_role_search_request_api_model.dart';

class UserRoleService {
  final String userRoleUrl = "${ApiConstants.baseUrl}/user-roles";

  Future<http.Response> search(UserRoleSearchRequestApiModel request) async {
    final fullPath = '$userRoleUrl/search';
    final queryParams = request.toJson().map(
      (key, value) => MapEntry(key, value.toString()),
    );
    final uri = Uri.parse(fullPath).replace(queryParameters: queryParams);
    final token = await TokenStorage.getAccessToken();

    return await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }
}

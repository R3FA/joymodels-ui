import 'package:http/http.dart' as http;
import 'package:joymodels_desktop/data/core/config/api_constants.dart';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';
import 'package:joymodels_desktop/data/model/user_role/request_types/user_role_create_request_api_model.dart';
import 'package:joymodels_desktop/data/model/user_role/request_types/user_role_patch_request_api_model.dart';
import 'package:joymodels_desktop/data/model/user_role/request_types/user_role_search_request_api_model.dart';

class UserRoleService {
  final String userRoleUrl = "${ApiConstants.baseUrl}/user-roles";

  Future<http.Response> getByUuid(String userRoleUuid) async {
    final url = Uri.parse('$userRoleUrl/get/$userRoleUuid');
    final token = await TokenStorage.getAccessToken();

    return await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }

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

  Future<http.Response> create(UserRoleCreateRequestApiModel request) async {
    final url = Uri.parse('$userRoleUrl/create');

    final multiPartRequest = await request.toMultipartRequest(url);

    final token = await TokenStorage.getAccessToken();
    multiPartRequest.headers['Authorization'] = 'Bearer $token';

    final streamedResponse = await multiPartRequest.send();

    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> patch(UserRolePatchRequestApiModel request) async {
    final url = Uri.parse('$userRoleUrl/edit-user-role');

    final multiPartRequest = await request.toMultipartRequest(url);

    final token = await TokenStorage.getAccessToken();
    multiPartRequest.headers['Authorization'] = 'Bearer $token';

    final streamedResponse = await multiPartRequest.send();

    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> delete(String userRoleUuid) async {
    final url = Uri.parse('$userRoleUrl/delete/$userRoleUuid');
    final token = await TokenStorage.getAccessToken();

    return await http.delete(url, headers: {'Authorization': 'Bearer $token'});
  }
}

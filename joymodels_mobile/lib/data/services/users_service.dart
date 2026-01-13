import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/model/users/request_types/user_search_request_api_model.dart';

class UsersService {
  final String usersUrl = "${ApiConstants.baseUrl}/users";

  Future<http.Response> getByUuid(String userUuid) async {
    final url = Uri.parse("$usersUrl/get/$userUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> getUserAvatar(String userUuid) async {
    final url = Uri.parse("$usersUrl/get/$userUuid/avatar");

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> search(UsersSearchRequestApiModel request) async {
    final url = Uri.parse(
      "$usersUrl/search",
    ).replace(queryParameters: request.toQueryParameters());

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> searchTopArtists(
    UsersSearchRequestApiModel request,
  ) async {
    final url = Uri.parse(
      "$usersUrl/search-top-artists",
    ).replace(queryParameters: request.toQueryParameters());

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }
}

import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/model/users/request_types/user_follower_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/users/request_types/user_model_likes_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/users/request_types/user_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/users/request_types/users_patch_request_api_model.dart';

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

  Future<http.Response> searchFollowingUsers(
    UserFollowerSearchRequestApiModel request,
  ) async {
    final url = Uri.parse(
      "$usersUrl/search-following-users",
    ).replace(queryParameters: request.toQueryParameters());

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> searchFollowerUsers(
    UserFollowerSearchRequestApiModel request,
  ) async {
    final url = Uri.parse(
      "$usersUrl/search-follower-users",
    ).replace(queryParameters: request.toQueryParameters());

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> searchUserModelLikes(
    UserModelLikesSearchRequestApiModel request,
  ) async {
    final url = Uri.parse(
      "$usersUrl/search-user-model-likes",
    ).replace(queryParameters: request.toQueryParameters());

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> isFollowingUser(String targetUserUuid) async {
    final url = Uri.parse("$usersUrl/is-following-user/$targetUserUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> followAnUser(String targetUserUuid) async {
    final url = Uri.parse("$usersUrl/follow-an-user/$targetUserUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.StreamedResponse> editUser(
    UsersPatchRequestApiModel request,
  ) async {
    final url = Uri.parse("$usersUrl/edit-user");

    final token = await TokenStorage.getAccessToken();

    final multipartRequest = await request.toMultipartRequest('PATCH', url);
    multipartRequest.headers['Authorization'] = 'Bearer $token';
    multipartRequest.headers['Accept'] = 'application/json';

    return await multipartRequest.send();
  }

  Future<http.Response> unfollowAnUser(String targetUserUuid) async {
    final url = Uri.parse("$usersUrl/unfollow-an-user/$targetUserUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> delete(String userUuid) async {
    final url = Uri.parse("$usersUrl/delete/$userUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }
}

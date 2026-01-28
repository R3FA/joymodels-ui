import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/model/core/response_types/picture_response_api_model.dart';
import 'package:joymodels_desktop/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_desktop/data/model/users/request_types/user_follower_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/users/request_types/user_model_likes_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/users/request_types/user_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/users/request_types/users_patch_request_api_model.dart';
import 'package:joymodels_desktop/data/model/users/response_types/user_follower_response_api_model.dart';
import 'package:joymodels_desktop/data/model/users/response_types/user_following_response_api_model.dart';
import 'package:joymodels_desktop/data/model/users/response_types/user_model_likes_search_response_api_model.dart';
import 'package:joymodels_desktop/data/model/users/response_types/users_response_api_model.dart';
import 'package:joymodels_desktop/data/services/users_service.dart';

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

  Future<PaginationResponseApiModel<UsersResponseApiModel>> searchTopArtists(
    UsersSearchRequestApiModel request,
  ) async {
    final response = await _authService.request(
      () => _service.searchTopArtists(request),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel<UsersResponseApiModel>.fromJson(
        jsonMap,
        (item) => UsersResponseApiModel.fromJson(item),
      );
    } else {
      throw Exception(
        'Failed to fetch top artists: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PaginationResponseApiModel<UserFollowingResponseApiModel>>
  searchFollowingUsers(UserFollowerSearchRequestApiModel request) async {
    final response = await _authService.request(
      () => _service.searchFollowingUsers(request),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel<UserFollowingResponseApiModel>.fromJson(
        jsonMap,
        (item) => UserFollowingResponseApiModel.fromJson(item),
      );
    } else {
      throw Exception(
        'Failed to fetch following users: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PaginationResponseApiModel<UserFollowerResponseApiModel>>
  searchFollowerUsers(UserFollowerSearchRequestApiModel request) async {
    final response = await _authService.request(
      () => _service.searchFollowerUsers(request),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel<UserFollowerResponseApiModel>.fromJson(
        jsonMap,
        (item) => UserFollowerResponseApiModel.fromJson(item),
      );
    } else {
      throw Exception(
        'Failed to fetch follower users: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PaginationResponseApiModel<UserModelLikesSearchResponseApiModel>>
  searchUserModelLikes(UserModelLikesSearchRequestApiModel request) async {
    final response = await _authService.request(
      () => _service.searchUserModelLikes(request),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel<
        UserModelLikesSearchResponseApiModel
      >.fromJson(
        jsonMap,
        (item) => UserModelLikesSearchResponseApiModel.fromJson(item),
      );
    } else {
      throw Exception(
        'Failed to fetch user model likes: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<bool> isFollowingUser(String targetUserUuid) async {
    final response = await _authService.request(
      () => _service.isFollowingUser(targetUserUuid),
    );

    if (response.statusCode == 200) {
      final body = response.body.trim().toLowerCase();
      if (body == 'true') {
        return true;
      } else if (body == 'false') {
        return false;
      } else {
        throw Exception('Unexpected response body: ${response.body}');
      }
    } else {
      throw Exception(
        'Failed to check if following user: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> followAnUser(String targetUserUuid) async {
    final response = await _authService.request(
      () => _service.followAnUser(targetUserUuid),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to follow user: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<UsersResponseApiModel> editUser(
    UsersPatchRequestApiModel request,
  ) async {
    final streamedResponse = await _authService.requestStreamed(
      () => _service.editUser(request),
    );

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return UsersResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to edit user: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> unfollowAnUser(String targetUserUuid) async {
    final response = await _authService.request(
      () => _service.unfollowAnUser(targetUserUuid),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to unfollow user: ${response.statusCode} - ${response.body}',
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

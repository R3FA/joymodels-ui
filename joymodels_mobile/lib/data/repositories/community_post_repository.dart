import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/services/auth_service.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_patch_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_search_reviewed_users_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_search_user_liked_posts_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_user_review_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_user_review_delete_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post/response_types/community_post_response_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post/response_types/community_post_user_review_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/services/community_post_service.dart';

class CommunityPostRepository {
  final CommunityPostService _service;
  final AuthService _authService;

  CommunityPostRepository(this._service, this._authService);

  Future<CommunityPostResponseApiModel> getByUuid(
    String communityPostUuid,
  ) async {
    final response = await _authService.request(
      () => _service.getByUuid(communityPostUuid),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return CommunityPostResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to fetch community post: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PaginationResponseApiModel<CommunityPostResponseApiModel>> search(
    CommunityPostSearchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.search(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel<CommunityPostResponseApiModel>.fromJson(
        jsonMap,
        (item) => CommunityPostResponseApiModel.fromJson(item),
      );
    } else {
      throw Exception(
        'Failed to search community posts: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PaginationResponseApiModel<CommunityPostUserReviewResponseApiModel>>
  searchReviewedUsers(
    CommunityPostSearchReviewedUsersRequestApiModel request,
  ) async {
    final response = await _authService.request(
      () => _service.searchReviewedUsers(request),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel<
        CommunityPostUserReviewResponseApiModel
      >.fromJson(
        jsonMap,
        (item) => CommunityPostUserReviewResponseApiModel.fromJson(item),
      );
    } else {
      throw Exception(
        'Failed to search reviewed users: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<CommunityPostResponseApiModel> create(
    CommunityPostCreateRequestApiModel request,
  ) async {
    final streamedResponse = await _authService.requestStreamed(
      () => _service.create(request),
    );

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return CommunityPostResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to create community post: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> createUserReview(
    CommunityPostUserReviewCreateRequestApiModel request,
  ) async {
    final streamedResponse = await _authService.requestStreamed(
      () => _service.createUserReview(request),
    );

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to create user review: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<CommunityPostResponseApiModel> patch(
    CommunityPostPatchRequestApiModel request,
  ) async {
    final streamedResponse = await _authService.requestStreamed(
      () => _service.patch(request),
    );

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return CommunityPostResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to patch community post: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> deleteUserReview(
    CommunityPostUserReviewDeleteRequestApiModel request,
  ) async {
    final streamedResponse = await _authService.requestStreamed(
      () => _service.deleteUserReview(request),
    );

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete user review: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> delete(String communityPostUuid) async {
    final response = await _authService.request(
      () => _service.delete(communityPostUuid),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete community post: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<bool> isLiked(String communityPostUuid) async {
    final response = await _authService.request(
      () => _service.isLiked(communityPostUuid),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception(
        'Failed to check if community post is liked: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<bool> isDisliked(String communityPostUuid) async {
    final response = await _authService.request(
      () => _service.isDisliked(communityPostUuid),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception(
        'Failed to check if community post is disliked: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PaginationResponseApiModel<CommunityPostResponseApiModel>>
  searchUsersLikedPosts(
    CommunityPostSearchUserLikedPostsRequestApiModel request,
  ) async {
    final response = await _authService.request(
      () => _service.searchUsersLikedPosts(request),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel<CommunityPostResponseApiModel>.fromJson(
        jsonMap,
        (item) => CommunityPostResponseApiModel.fromJson(item),
      );
    } else {
      throw Exception(
        'Failed to search users liked posts: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

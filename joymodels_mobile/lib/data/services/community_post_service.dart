import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_patch_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_search_reviewed_users_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_user_review_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_user_review_delete_request_api_model.dart';

class CommunityPostService {
  final String communityPostsUrl = "${ApiConstants.baseUrl}/community-posts";

  Future<http.Response> getByUuid(String communityPostUuid) async {
    final url = Uri.parse("$communityPostsUrl/get/$communityPostUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> search(
    CommunityPostSearchRequestApiModel request,
  ) async {
    final url = Uri.parse(
      "$communityPostsUrl/search",
    ).replace(queryParameters: request.toQueryParameters());

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> searchReviewedUsers(
    CommunityPostSearchReviewedUsersRequestApiModel request,
  ) async {
    final url = Uri.parse(
      "$communityPostsUrl/search-reviewed-users",
    ).replace(queryParameters: request.toQueryParameters());

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.StreamedResponse> create(
    CommunityPostCreateRequestApiModel request,
  ) async {
    final url = Uri.parse("$communityPostsUrl/create");

    final token = await TokenStorage.getAccessToken();

    final multipartRequest = await request.toMultipartRequest('POST', url);
    multipartRequest.headers['Authorization'] = 'Bearer $token';
    multipartRequest.headers['Accept'] = 'application/json';

    return await multipartRequest.send();
  }

  Future<http.StreamedResponse> createUserReview(
    CommunityPostUserReviewCreateRequestApiModel request,
  ) async {
    final url = Uri.parse("$communityPostsUrl/create-user-review");

    final token = await TokenStorage.getAccessToken();

    final multipartRequest = await request.toMultipartRequest('POST', url);
    multipartRequest.headers['Authorization'] = 'Bearer $token';
    multipartRequest.headers['Accept'] = 'application/json';

    return await multipartRequest.send();
  }

  Future<http.StreamedResponse> patch(
    CommunityPostPatchRequestApiModel request,
  ) async {
    final url = Uri.parse("$communityPostsUrl/edit-community-post");

    final token = await TokenStorage.getAccessToken();

    final multipartRequest = await request.toMultipartRequest('PATCH', url);
    multipartRequest.headers['Authorization'] = 'Bearer $token';
    multipartRequest.headers['Accept'] = 'application/json';

    return await multipartRequest.send();
  }

  Future<http.StreamedResponse> deleteUserReview(
    CommunityPostUserReviewDeleteRequestApiModel request,
  ) async {
    final url = Uri.parse("$communityPostsUrl/delete-user-review");

    final token = await TokenStorage.getAccessToken();

    final multipartRequest = await request.toMultipartRequest('DELETE', url);
    multipartRequest.headers['Authorization'] = 'Bearer $token';
    multipartRequest.headers['Accept'] = 'application/json';

    return await multipartRequest.send();
  }

  Future<http.Response> delete(String communityPostUuid) async {
    final url = Uri.parse("$communityPostsUrl/delete/$communityPostUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> isLiked(String communityPostUuid) async {
    final url = Uri.parse("$communityPostsUrl/is-liked/$communityPostUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> isDisliked(String communityPostUuid) async {
    final url = Uri.parse("$communityPostsUrl/is-disliked/$communityPostUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }
}

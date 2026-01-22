import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/model/community_post_review_type/request_types/community_post_review_type_search_request_api_model.dart';

class CommunityPostReviewTypeService {
  final String communityPostReviewTypesUrl =
      "${ApiConstants.baseUrl}/community-post-review-types";

  Future<http.Response> getByUuid(String communityPostReviewTypeUuid) async {
    final url = Uri.parse(
      "$communityPostReviewTypesUrl/get/$communityPostReviewTypeUuid",
    );

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> search(
    CommunityPostReviewTypeSearchRequestApiModel request,
  ) async {
    final url = Uri.parse(
      "$communityPostReviewTypesUrl/search",
    ).replace(queryParameters: request.toQueryParameters());

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }
}

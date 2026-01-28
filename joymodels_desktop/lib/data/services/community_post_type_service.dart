import 'package:http/http.dart' as http;
import 'package:joymodels_desktop/data/core/config/api_constants.dart';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';
import 'package:joymodels_desktop/data/model/community_post_type/request_types/community_post_type_create_request_api_model.dart';
import 'package:joymodels_desktop/data/model/community_post_type/request_types/community_post_type_patch_request_api_model.dart';
import 'package:joymodels_desktop/data/model/community_post_type/request_types/community_post_type_search_request_api_model.dart';

class CommunityPostTypeService {
  final String communityPostTypesUrl =
      "${ApiConstants.baseUrl}/community-post-types";

  Future<http.Response> getByUuid(String communityPostTypeUuid) async {
    final url = Uri.parse("$communityPostTypesUrl/get/$communityPostTypeUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> search(
    CommunityPostTypeSearchRequestApiModel request,
  ) async {
    final url = Uri.parse(
      "$communityPostTypesUrl/search",
    ).replace(queryParameters: request.toQueryParameters());

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> create(
    CommunityPostTypeCreateRequestApiModel request,
  ) async {
    final url = Uri.parse('$communityPostTypesUrl/create');

    final multiPartRequest = await request.toMultipartRequest(url);

    final token = await TokenStorage.getAccessToken();
    multiPartRequest.headers['Authorization'] = 'Bearer $token';

    final streamedResponse = await multiPartRequest.send();

    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> patch(
    CommunityPostTypePatchRequestApiModel request,
  ) async {
    final url = Uri.parse('$communityPostTypesUrl/edit-community-post-type');

    final multiPartRequest = await request.toMultipartRequest(url);

    final token = await TokenStorage.getAccessToken();
    multiPartRequest.headers['Authorization'] = 'Bearer $token';

    final streamedResponse = await multiPartRequest.send();

    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> delete(String communityPostTypeUuid) async {
    final url = Uri.parse(
      '$communityPostTypesUrl/delete/$communityPostTypeUuid',
    );
    final token = await TokenStorage.getAccessToken();

    return await http.delete(url, headers: {'Authorization': 'Bearer $token'});
  }
}

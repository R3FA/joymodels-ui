import 'dart:convert';
import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/model/community_post_type/request_types/community_post_type_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/community_post_type/response_types/community_post_type_response_api_model.dart';
import 'package:joymodels_desktop/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_desktop/data/services/community_post_type_service.dart';

class CommunityPostTypeRepository {
  final CommunityPostTypeService _service;
  final AuthService _authService;

  CommunityPostTypeRepository(this._service, this._authService);

  Future<CommunityPostTypeResponseApiModel> getByUuid(
    String communityPostTypeUuid,
  ) async {
    final response = await _authService.request(
      () => _service.getByUuid(communityPostTypeUuid),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return CommunityPostTypeResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to fetch community post type: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PaginationResponseApiModel<CommunityPostTypeResponseApiModel>> search(
    CommunityPostTypeSearchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.search(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel<
        CommunityPostTypeResponseApiModel
      >.fromJson(
        jsonMap,
        (item) => CommunityPostTypeResponseApiModel.fromJson(item),
      );
    } else {
      throw Exception(
        'Failed to fetch community post types: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

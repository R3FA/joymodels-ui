import 'dart:convert';
import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/model/community_post_review_type/request_types/community_post_review_type_create_request_api_model.dart';
import 'package:joymodels_desktop/data/model/community_post_review_type/request_types/community_post_review_type_patch_request_api_model.dart';
import 'package:joymodels_desktop/data/model/community_post_review_type/request_types/community_post_review_type_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/community_post_review_type/response_types/community_post_review_type_response_api_model.dart';
import 'package:joymodels_desktop/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_desktop/data/services/community_post_review_type_service.dart';

class CommunityPostReviewTypeRepository {
  final CommunityPostReviewTypeService _service;
  final AuthService _authService;

  CommunityPostReviewTypeRepository(this._service, this._authService);

  Future<CommunityPostReviewTypeResponseApiModel> getByUuid(
    String communityPostReviewTypeUuid,
  ) async {
    final response = await _authService.request(
      () => _service.getByUuid(communityPostReviewTypeUuid),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return CommunityPostReviewTypeResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to fetch community post review type: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PaginationResponseApiModel<CommunityPostReviewTypeResponseApiModel>>
  search(CommunityPostReviewTypeSearchRequestApiModel request) async {
    final response = await _authService.request(() => _service.search(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel<
        CommunityPostReviewTypeResponseApiModel
      >.fromJson(
        jsonMap,
        (item) => CommunityPostReviewTypeResponseApiModel.fromJson(item),
      );
    } else {
      throw Exception(
        'Failed to fetch community post review types: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<CommunityPostReviewTypeResponseApiModel> create(
    CommunityPostReviewTypeCreateRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.create(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return CommunityPostReviewTypeResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to create community post review type: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<CommunityPostReviewTypeResponseApiModel> patch(
    CommunityPostReviewTypePatchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.patch(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return CommunityPostReviewTypeResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to update community post review type: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> delete(String communityPostReviewTypeUuid) async {
    final response = await _authService.request(
      () => _service.delete(communityPostReviewTypeUuid),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete community post review type: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

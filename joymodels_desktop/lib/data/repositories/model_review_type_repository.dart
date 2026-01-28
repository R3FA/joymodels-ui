import 'dart:convert';
import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/model/model_review_type/request_types/model_review_type_create_request_api_model.dart';
import 'package:joymodels_desktop/data/model/model_review_type/request_types/model_review_type_patch_request_api_model.dart';
import 'package:joymodels_desktop/data/model/model_review_type/request_types/model_review_type_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/model_review_type/response_types/model_review_type_response_api_model.dart';
import 'package:joymodels_desktop/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_desktop/data/services/model_review_type_service.dart';

class ModelReviewTypeRepository {
  final ModelReviewTypeService _service;
  final AuthService _authService;

  ModelReviewTypeRepository(this._service, this._authService);

  Future<ModelReviewTypeResponseApiModel> getByUuid(
    String modelReviewTypeUuid,
  ) async {
    final response = await _authService.request(
      () => _service.getByUuid(modelReviewTypeUuid),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return ModelReviewTypeResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to get model review type: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PaginationResponseApiModel<ModelReviewTypeResponseApiModel>> search(
    ModelReviewTypeSearchRequestApiModel request,
  ) async {
    final response = await _authService.request(
      () => _service.search(request.toQueryParameters()),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel.fromJson(
        jsonMap,
        (json) => ModelReviewTypeResponseApiModel.fromJson(json),
      );
    } else {
      throw Exception(
        'Failed to search model review types: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<ModelReviewTypeResponseApiModel> create(
    ModelReviewTypeCreateRequestApiModel request,
  ) async {
    final response = await _authService.request(
      () => _service.create(request.toFormData()),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return ModelReviewTypeResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to create model review type: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<ModelReviewTypeResponseApiModel> patch(
    ModelReviewTypePatchRequestApiModel request,
  ) async {
    final response = await _authService.request(
      () => _service.patch(request.toFormData()),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return ModelReviewTypeResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to patch model review type: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> delete(String modelReviewTypeUuid) async {
    final response = await _authService.request(
      () => _service.delete(modelReviewTypeUuid),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete model review type: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

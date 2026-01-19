import 'dart:convert';
import 'package:joymodels_mobile/data/core/services/auth_service.dart';
import 'package:joymodels_mobile/data/model/model_reviews/request_types/model_review_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_reviews/request_types/model_review_patch_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_reviews/request_types/model_review_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_reviews/response_types/model_calculated_reviews_response_api_model.dart';
import 'package:joymodels_mobile/data/model/model_reviews/response_types/model_review_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/services/model_reviews_service.dart';

class ModelReviewsRepository {
  final ModelReviewsService _service;
  final AuthService _authService;

  ModelReviewsRepository(this._service, this._authService);

  Future<ModelCalculatedReviewsResponseApiModel> calculateReviews(
    String modelUuid,
  ) async {
    final response = await _authService.request(
      () => _service.calculateReviews(modelUuid),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return ModelCalculatedReviewsResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to calculate reviews for model with sent uuid: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PaginationResponseApiModel<ModelReviewResponseApiModel>> search(
    ModelReviewSearchRequestApiModel request,
  ) async {
    final response = await _authService.request(
      () => _service.search(request.toQueryParameters()),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel.fromJson(
        jsonMap,
        (json) => ModelReviewResponseApiModel.fromJson(json),
      );
    } else {
      throw Exception(
        'Failed to search model reviews: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<ModelReviewResponseApiModel> create(
    ModelReviewCreateRequestApiModel request,
  ) async {
    final response = await _authService.request(
      () => _service.create(request.toFormData()),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return ModelReviewResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to create model review: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<ModelReviewResponseApiModel> patch(
    ModelReviewPatchRequestApiModel request,
  ) async {
    final response = await _authService.request(
      () => _service.patch(request.toFormData()),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return ModelReviewResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to patch model review: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> delete(String modelReviewUuid) async {
    final response = await _authService.request(
      () => _service.delete(modelReviewUuid),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete model review: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<bool> hasUserReviewed(String modelUuid) async {
    final response = await _authService.request(
      () => _service.hasUserReviewed(modelUuid),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception(
        'Failed to check if user reviewed: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

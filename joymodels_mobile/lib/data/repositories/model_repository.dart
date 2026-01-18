import 'dart:convert';
import 'package:joymodels_mobile/data/core/services/auth_service.dart';
import 'package:joymodels_mobile/data/model/core/response_types/picture_response_api_model.dart';
import 'package:joymodels_mobile/data/model/models/request_types/model_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/models/request_types/model_patch_request_api_model.dart';
import 'package:joymodels_mobile/data/model/models/request_types/model_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/services/model_service.dart';

class ModelRepository {
  final ModelService _service;
  final AuthService _authService;

  ModelRepository(this._service, this._authService);

  Future<PictureResponse> getModelPictures(
    String modelUuid,
    String modelPictureLocationPath,
  ) async {
    final response = await _authService.request(
      () => _service.getModelPictures(modelUuid, modelPictureLocationPath),
    );

    if (response.statusCode == 200) {
      final contentType =
          response.headers['content-type'] ?? 'application/octet-stream';
      final fileBytes = response.bodyBytes;
      return PictureResponse(fileBytes: fileBytes, contentType: contentType);
    } else {
      throw Exception(
        'Failed to fetch model picture by its uuid: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PaginationResponseApiModel<ModelResponseApiModel>> search(
    ModelSearchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.search(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel<ModelResponseApiModel>.fromJson(
        jsonMap,
        (item) => ModelResponseApiModel.fromJson(item),
      );
    } else {
      throw Exception(
        'Failed to fetch models: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<bool> isModelLiked(String modelUuid) async {
    final response = await _authService.request(
      () => _service.isModelLiked(modelUuid),
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
        'Failed to check if model is liked by its uuid: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<ModelResponseApiModel> create(
    ModelCreateRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.create(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return ModelResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to create model: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> modelLike(String modelUuid) async {
    final response = await _authService.request(
      () => _service.modelLike(modelUuid),
    );

    if (response.statusCode == 204) {
      return;
    } else {
      throw Exception(
        'Failed to like model by its uuid: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<ModelResponseApiModel> patch(ModelPatchRequestApiModel request) async {
    final response = await _authService.request(() => _service.patch(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return ModelResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to patch model: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> modelUnlike(String modelUuid) async {
    final response = await _authService.request(
      () => _service.modelUnlike(modelUuid),
    );

    if (response.statusCode == 204) {
      return;
    } else {
      throw Exception(
        'Failed to unlike model by its uuid: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> delete(String modelUuid) async {
    final response = await _authService.request(
      () => _service.delete(modelUuid),
    );

    if (response.statusCode == 204) {
      return;
    } else {
      throw Exception(
        'Failed to delete model by its uuid: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

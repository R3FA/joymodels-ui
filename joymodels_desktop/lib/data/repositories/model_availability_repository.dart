import 'dart:convert';
import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/model/model_availability/request_types/model_availability_create_request_api_model.dart';
import 'package:joymodels_desktop/data/model/model_availability/request_types/model_availability_patch_request_api_model.dart';
import 'package:joymodels_desktop/data/model/model_availability/request_types/model_availability_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/model_availability/response_types/model_availability_response_api_model.dart';
import 'package:joymodels_desktop/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_desktop/data/services/model_availability_service.dart';

class ModelAvailabilityRepository {
  final ModelAvailabilityService _service;
  final AuthService _authService;

  ModelAvailabilityRepository(this._service, this._authService);
  Future<PaginationResponseApiModel<ModelAvailabilityResponseApiModel>> search(
    ModelAvailabilitySearchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.search(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel<
        ModelAvailabilityResponseApiModel
      >.fromJson(
        jsonMap,
        (item) => ModelAvailabilityResponseApiModel.fromJson(item),
      );
    } else {
      throw Exception(
        'Failed to fetch categories: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<ModelAvailabilityResponseApiModel> getByUuid(
    String modelAvailabilityUuid,
  ) async {
    final response = await _authService.request(
      () => _service.getByUuid(modelAvailabilityUuid),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return ModelAvailabilityResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to fetch model availability: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<ModelAvailabilityResponseApiModel> create(
    ModelAvailabilityCreateRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.create(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return ModelAvailabilityResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to create model availability: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<ModelAvailabilityResponseApiModel> patch(
    ModelAvailabilityPatchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.patch(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return ModelAvailabilityResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to update model availability: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> delete(String modelAvailabilityUuid) async {
    final response = await _authService.request(
      () => _service.delete(modelAvailabilityUuid),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete model availability: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

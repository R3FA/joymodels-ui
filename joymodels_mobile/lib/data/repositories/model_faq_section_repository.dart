import 'dart:convert';
import 'package:joymodels_mobile/data/core/services/auth_service.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/request_types/model_faq_section_create_answer_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/request_types/model_faq_section_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/request_types/model_faq_section_delete_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/request_types/model_faq_section_patch_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/request_types/model_faq_section_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/response_types/model_faq_section_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/services/model_faq_section_service.dart';

class ModelFaqSectionRepository {
  final ModelFaqSectionService _service;
  final AuthService _authService;

  ModelFaqSectionRepository(this._service, this._authService);

  Future<PaginationResponseApiModel<ModelFaqSectionResponseApiModel>> search(
    ModelFaqSectionSearchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.search(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return PaginationResponseApiModel.fromJson(
        jsonMap,
        (json) => ModelFaqSectionResponseApiModel.fromJson(json),
      );
    } else {
      throw Exception(
        'Failed to search FAQ: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<ModelFaqSectionResponseApiModel> getByUuid(
    String modelFaqSectionUuid,
  ) async {
    final response = await _authService.request(
      () => _service.getByUuid(modelFaqSectionUuid),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return ModelFaqSectionResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to fetch FAQ: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<ModelFaqSectionResponseApiModel> create(
    ModelFaqSectionCreateRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.create(request));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return ModelFaqSectionResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to create FAQ: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<ModelFaqSectionResponseApiModel> createAnswer(
    ModelFaqSectionCreateAnswerRequestApiModel request,
  ) async {
    final response = await _authService.request(
      () => _service.createAnswer(request),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return ModelFaqSectionResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to create FAQ answer: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<ModelFaqSectionResponseApiModel> patch(
    ModelFaqSectionPatchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.patch(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return ModelFaqSectionResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to update FAQ: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> delete(ModelFaqSectionDeleteRequestApiModel request) async {
    final response = await _authService.request(() => _service.delete(request));

    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    } else {
      throw Exception(
        'Failed to delete FAQ: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

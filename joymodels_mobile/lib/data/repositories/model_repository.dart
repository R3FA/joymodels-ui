import 'dart:convert';
import 'package:joymodels_mobile/data/core/services/auth_service.dart';
import 'package:joymodels_mobile/data/model/models/request_types/model_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/services/model_service.dart';

class ModelRepository {
  final ModelService _service;
  final AuthService _authService;

  ModelRepository(this._service, this._authService);

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
}

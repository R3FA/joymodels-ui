import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/model/model_availability/request_types/model_availability_search_request_api_model.dart';

class ModelAvailabilityService {
  final String modelAvailabilityUrl =
      "${ApiConstants.baseUrl}/model-availability";

  Future<http.Response> search(
    ModelAvailabilitySearchRequestApiModel request,
  ) async {
    final fullPath = '$modelAvailabilityUrl/search';

    final queryParams = request.toJson().map(
      (key, value) => MapEntry(key, value.toString()),
    );

    final uri = Uri.parse(fullPath).replace(queryParameters: queryParams);

    final token = await TokenStorage.getAccessToken();

    return await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }
}

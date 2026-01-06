import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/model/models/request_types/model_search_request_api_model.dart';

class ModelService {
  final String modelsUrl = "${ApiConstants.baseUrl}/models";

  Future<http.Response> search(ModelSearchRequestApiModel request) async {
    final url = Uri.parse(
      "$modelsUrl/search",
    ).replace(queryParameters: request.toQueryParameters());

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }
}

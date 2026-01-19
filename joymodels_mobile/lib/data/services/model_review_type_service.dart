import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';

class ModelReviewTypeService {
  final String modelReviewTypesUrl =
      "${ApiConstants.baseUrl}/model-review-types";

  Future<http.Response> getByUuid(String modelReviewTypeUuid) async {
    final url = Uri.parse("$modelReviewTypesUrl/get/$modelReviewTypeUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> search(Map<String, String> queryParameters) async {
    final url = Uri.parse(
      "$modelReviewTypesUrl/search",
    ).replace(queryParameters: queryParameters);

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> create(Map<String, String> formData) async {
    final url = Uri.parse("$modelReviewTypesUrl/create");

    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: formData,
    );

    return response;
  }

  Future<http.Response> patch(Map<String, String> formData) async {
    final url = Uri.parse("$modelReviewTypesUrl/edit-model-review-type");

    final token = await TokenStorage.getAccessToken();

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: formData,
    );

    return response;
  }

  Future<http.Response> delete(String modelReviewTypeUuid) async {
    final url = Uri.parse("$modelReviewTypesUrl/delete/$modelReviewTypeUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }
}

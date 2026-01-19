import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';

class ModelReviewsService {
  final String modelReviewsUrl = "${ApiConstants.baseUrl}/model-reviews";

  Future<http.Response> calculateReviews(String modelUuid) async {
    final url = Uri.parse("$modelReviewsUrl/calculate-reviews/$modelUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> search(Map<String, String> queryParameters) async {
    final url = Uri.parse(
      "$modelReviewsUrl/search",
    ).replace(queryParameters: queryParameters);

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> create(Map<String, String> formData) async {
    final url = Uri.parse("$modelReviewsUrl/create");

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
    final url = Uri.parse("$modelReviewsUrl/edit-model-review");

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

  Future<http.Response> delete(String modelReviewUuid) async {
    final url = Uri.parse("$modelReviewsUrl/delete/$modelReviewUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> hasUserReviewed(String modelUuid) async {
    final url = Uri.parse("$modelReviewsUrl/has-user-reviewed/$modelUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }
}

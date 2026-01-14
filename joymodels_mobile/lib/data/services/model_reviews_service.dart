import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';

class ModelReviewsService {
  final String modelAvailabilityUrl = "${ApiConstants.baseUrl}/model-reviews";

  Future<http.Response> calculateReviews(String modelUuid) async {
    final url = Uri.parse("$modelAvailabilityUrl/calculate-reviews/$modelUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }
}

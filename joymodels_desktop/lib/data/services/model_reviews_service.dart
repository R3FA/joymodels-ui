import 'package:http/http.dart' as http;
import 'package:joymodels_desktop/data/core/config/api_constants.dart';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';

class ModelReviewsService {
  final String modelReviewsUrl = "${ApiConstants.baseUrl}/model-reviews";

  Future<http.Response> delete(String modelReviewUuid) async {
    final url = Uri.parse("$modelReviewsUrl/delete/$modelReviewUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }
}

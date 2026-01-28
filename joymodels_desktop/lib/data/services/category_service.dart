import 'package:http/http.dart' as http;
import 'package:joymodels_desktop/data/core/config/api_constants.dart';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';
import 'package:joymodels_desktop/data/model/category/request_types/category_request_api_model.dart';

class CategoryService {
  final String categoryUrl = "${ApiConstants.baseUrl}/categories";

  Future<http.Response> search(CategorySearchRequestApiModel request) async {
    final fullPath = '$categoryUrl/search';

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

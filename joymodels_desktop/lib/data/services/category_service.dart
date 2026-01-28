import 'package:http/http.dart' as http;
import 'package:joymodels_desktop/data/core/config/api_constants.dart';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';
import 'package:joymodels_desktop/data/model/category/request_types/category_create_request_api_model.dart';
import 'package:joymodels_desktop/data/model/category/request_types/category_patch_request_api_model.dart';
import 'package:joymodels_desktop/data/model/category/request_types/category_request_api_model.dart';

class CategoryService {
  final String categoryUrl = "${ApiConstants.baseUrl}/categories";

  Future<http.Response> getByUuid(String categoryUuid) async {
    final url = Uri.parse('$categoryUrl/get/$categoryUuid');
    final token = await TokenStorage.getAccessToken();

    return await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );
  }

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

  Future<http.Response> create(CategoryCreateRequestApiModel request) async {
    final url = Uri.parse('$categoryUrl/create');

    final multiPartRequest = await request.toMultipartRequest(url);

    final token = await TokenStorage.getAccessToken();
    multiPartRequest.headers['Authorization'] = 'Bearer $token';

    final streamedResponse = await multiPartRequest.send();

    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> patch(CategoryPatchRequestApiModel request) async {
    final url = Uri.parse('$categoryUrl/edit-category');

    final multiPartRequest = await request.toMultipartRequest(url);

    final token = await TokenStorage.getAccessToken();
    multiPartRequest.headers['Authorization'] = 'Bearer $token';

    final streamedResponse = await multiPartRequest.send();

    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> delete(String categoryUuid) async {
    final url = Uri.parse('$categoryUrl/delete/$categoryUuid');
    final token = await TokenStorage.getAccessToken();

    return await http.delete(url, headers: {'Authorization': 'Bearer $token'});
  }
}

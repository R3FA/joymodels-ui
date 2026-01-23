import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/model/library/request_types/library_search_request_api_model.dart';

class LibraryService {
  final String libraryUrl = "${ApiConstants.baseUrl}/library";

  Future<http.Response> getByUuid(String libraryUuid) async {
    final url = Uri.parse("$libraryUrl/get/$libraryUuid");
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> getByModelUuid(String modelUuid) async {
    final url = Uri.parse("$libraryUrl/get-by-model/$modelUuid");
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> search(LibrarySearchRequestApiModel request) async {
    final queryParams = request.toQueryParameters();
    final uri = Uri.parse(
      "$libraryUrl/search",
    ).replace(queryParameters: queryParams);
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> hasPurchasedModel(String modelUuid) async {
    final url = Uri.parse("$libraryUrl/has-purchased/$modelUuid");
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> downloadModel(String modelUuid) async {
    final url = Uri.parse("$libraryUrl/download/$modelUuid");
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }
}

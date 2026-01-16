import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/model/models/request_types/model_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/models/request_types/model_search_request_api_model.dart';

class ModelService {
  final String modelsUrl = "${ApiConstants.baseUrl}/models";

  Future<http.Response> getModelPictures(
    String modelUuid,
    String modelPictureLocationPath,
  ) async {
    final url = Uri.parse(
      "$modelsUrl/get/$modelUuid/images/${Uri.encodeComponent(modelPictureLocationPath)}",
    );

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

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

  Future<http.Response> isModelLiked(String modelUuid) async {
    final url = Uri.parse("$modelsUrl/is-model-liked/$modelUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> create(ModelCreateRequestApiModel request) async {
    final url = Uri.parse("$modelsUrl/create");

    final multiPartRequest = await request.toMultipartRequest(url);

    final token = await TokenStorage.getAccessToken();
    multiPartRequest.headers['Authorization'] = "Bearer $token";

    final streamedResponse = await multiPartRequest.send();

    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> modelLike(String modelUuid) async {
    final url = Uri.parse("$modelsUrl/model-like/$modelUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> modelUnlike(String modelUuid) async {
    final url = Uri.parse("$modelsUrl/model-unlike/$modelUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> delete(String modelUuid) async {
    final url = Uri.parse("$modelsUrl/delete/$modelUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }
}

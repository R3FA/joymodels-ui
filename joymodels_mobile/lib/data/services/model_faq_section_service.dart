import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/request_types/model_faq_section_create_answer_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/request_types/model_faq_section_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/request_types/model_faq_section_delete_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/request_types/model_faq_section_patch_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/request_types/model_faq_section_search_request_api_model.dart';

class ModelFaqSectionService {
  final String faqUrl = "${ApiConstants.baseUrl}/model-faq-section";

  Future<http.Response> search(
    ModelFaqSectionSearchRequestApiModel request,
  ) async {
    final url = Uri.parse(
      "$faqUrl/search",
    ).replace(queryParameters: request.toQueryParameters());
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> getByUuid(String modelFaqSectionUuid) async {
    final url = Uri.parse("$faqUrl/get/$modelFaqSectionUuid");
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> create(
    ModelFaqSectionCreateRequestApiModel request,
  ) async {
    final url = Uri.parse("$faqUrl/create");
    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: request.toFormData(),
    );

    return response;
  }

  Future<http.Response> createAnswer(
    ModelFaqSectionCreateAnswerRequestApiModel request,
  ) async {
    final url = Uri.parse("$faqUrl/create-answer");
    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: request.toFormData(),
    );

    return response;
  }

  Future<http.Response> patch(
    ModelFaqSectionPatchRequestApiModel request,
  ) async {
    final url = Uri.parse("$faqUrl/patch");
    final token = await TokenStorage.getAccessToken();

    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: request.toFormData(),
    );

    return response;
  }

  Future<http.Response> delete(
    ModelFaqSectionDeleteRequestApiModel request,
  ) async {
    final url = Uri.parse("$faqUrl/delete").replace(
      queryParameters: {'modelFaqSectionUuid': request.modelFaqSectionUuid},
    );
    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }
}

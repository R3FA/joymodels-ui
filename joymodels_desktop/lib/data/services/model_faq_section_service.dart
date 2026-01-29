import 'package:http/http.dart' as http;
import 'package:joymodels_desktop/data/core/config/api_constants.dart';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';
import 'package:joymodels_desktop/data/model/model_faq_section/request_types/model_faq_section_delete_request_api_model.dart';

class ModelFaqSectionService {
  final String faqUrl = "${ApiConstants.baseUrl}/model-faq-section";

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

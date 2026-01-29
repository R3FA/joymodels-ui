import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/model/model_faq_section/request_types/model_faq_section_delete_request_api_model.dart';
import 'package:joymodels_desktop/data/services/model_faq_section_service.dart';

class ModelFaqSectionRepository {
  final ModelFaqSectionService _service;
  final AuthService _authService;

  ModelFaqSectionRepository(this._service, this._authService);

  Future<void> delete(ModelFaqSectionDeleteRequestApiModel request) async {
    final response = await _authService.request(() => _service.delete(request));

    if (response.statusCode == 204 || response.statusCode == 200) {
      return;
    } else {
      throw Exception(
        'Failed to delete FAQ: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/services/model_reviews_service.dart';

class ModelReviewsRepository {
  final ModelReviewsService _service;
  final AuthService _authService;

  ModelReviewsRepository(this._service, this._authService);

  Future<void> delete(String modelReviewUuid) async {
    final response = await _authService.request(
      () => _service.delete(modelReviewUuid),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete model review: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

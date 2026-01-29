import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/services/community_post_question_section_service.dart';

class CommunityPostQuestionSectionRepository {
  final CommunityPostQuestionSectionService _service;
  final AuthService _authService;

  CommunityPostQuestionSectionRepository(this._service, this._authService);

  Future<void> delete(String communityPostQuestionSectionUuid) async {
    final response = await _authService.request(
      () => _service.delete(communityPostQuestionSectionUuid),
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception(
        'Failed to delete community post question section: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

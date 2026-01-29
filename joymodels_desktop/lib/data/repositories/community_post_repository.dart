import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/services/community_post_service.dart';

class CommunityPostRepository {
  final CommunityPostService _service;
  final AuthService _authService;

  CommunityPostRepository(this._service, this._authService);

  Future<void> delete(String communityPostUuid) async {
    final response = await _authService.request(
      () => _service.delete(communityPostUuid),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete community post: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

import 'package:http/http.dart' as http;
import 'package:joymodels_desktop/data/core/config/api_constants.dart';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';

class CommunityPostService {
  final String communityPostsUrl = "${ApiConstants.baseUrl}/community-posts";

  Future<http.Response> delete(String communityPostUuid) async {
    final url = Uri.parse("$communityPostsUrl/delete/$communityPostUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }
}

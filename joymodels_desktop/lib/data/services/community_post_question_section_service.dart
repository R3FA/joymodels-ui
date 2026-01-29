import 'package:http/http.dart' as http;
import 'package:joymodels_desktop/data/core/config/api_constants.dart';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';

class CommunityPostQuestionSectionService {
  final String communityPostQuestionSectionUrl =
      "${ApiConstants.baseUrl}/community-post-question-section";

  Future<http.Response> delete(String communityPostQuestionSectionUuid) async {
    final url = Uri.parse(
      "$communityPostQuestionSectionUrl/delete/$communityPostQuestionSectionUuid",
    );

    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }
}

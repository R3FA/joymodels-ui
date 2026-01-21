import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/model/community_post_question_section/request_types/community_post_question_section_create_answer_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post_question_section/request_types/community_post_question_section_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post_question_section/request_types/community_post_question_section_patch_request_api_model.dart';

class CommunityPostQuestionSectionService {
  final String communityPostQuestionSectionUrl =
      "${ApiConstants.baseUrl}/community-post-question-section";

  Future<http.Response> getByUuid(
    String communityPostQuestionSectionUuid,
  ) async {
    final url = Uri.parse(
      "$communityPostQuestionSectionUrl/get/$communityPostQuestionSectionUuid",
    );

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.StreamedResponse> create(
    CommunityPostQuestionSectionCreateRequestApiModel request,
  ) async {
    final url = Uri.parse("$communityPostQuestionSectionUrl/create");

    final token = await TokenStorage.getAccessToken();

    final multipartRequest = await request.toMultipartRequest('POST', url);
    multipartRequest.headers['Authorization'] = 'Bearer $token';
    multipartRequest.headers['Accept'] = 'application/json';

    return await multipartRequest.send();
  }

  Future<http.StreamedResponse> createAnswer(
    CommunityPostQuestionSectionCreateAnswerRequestApiModel request,
  ) async {
    final url = Uri.parse("$communityPostQuestionSectionUrl/create-answer");

    final token = await TokenStorage.getAccessToken();

    final multipartRequest = await request.toMultipartRequest('POST', url);
    multipartRequest.headers['Authorization'] = 'Bearer $token';
    multipartRequest.headers['Accept'] = 'application/json';

    return await multipartRequest.send();
  }

  Future<http.StreamedResponse> patch(
    CommunityPostQuestionSectionPatchRequestApiModel request,
  ) async {
    final url = Uri.parse("$communityPostQuestionSectionUrl/patch");

    final token = await TokenStorage.getAccessToken();

    final multipartRequest = await request.toMultipartRequest('PATCH', url);
    multipartRequest.headers['Authorization'] = 'Bearer $token';
    multipartRequest.headers['Accept'] = 'application/json';

    return await multipartRequest.send();
  }

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

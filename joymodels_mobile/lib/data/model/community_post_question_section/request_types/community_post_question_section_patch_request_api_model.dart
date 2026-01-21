import 'package:http/http.dart' as http;

class CommunityPostQuestionSectionPatchRequestApiModel {
  final String communityPostQuestionSectionUuid;
  final String messageText;

  CommunityPostQuestionSectionPatchRequestApiModel({
    required this.communityPostQuestionSectionUuid,
    required this.messageText,
  });

  Future<http.MultipartRequest> toMultipartRequest(
    String method,
    Uri url,
  ) async {
    final request = http.MultipartRequest(method, url);

    request.fields['communityPostQuestionSectionUuid'] =
        communityPostQuestionSectionUuid;
    request.fields['messageText'] = messageText;

    return request;
  }
}

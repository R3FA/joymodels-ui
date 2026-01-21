import 'package:http/http.dart' as http;

class CommunityPostQuestionSectionCreateAnswerRequestApiModel {
  final String communityPostUuid;
  final String parentMessageUuid;
  final String messageText;

  CommunityPostQuestionSectionCreateAnswerRequestApiModel({
    required this.communityPostUuid,
    required this.parentMessageUuid,
    required this.messageText,
  });

  Future<http.MultipartRequest> toMultipartRequest(
    String method,
    Uri url,
  ) async {
    final request = http.MultipartRequest(method, url);

    request.fields['communityPostUuid'] = communityPostUuid;
    request.fields['parentMessageUuid'] = parentMessageUuid;
    request.fields['messageText'] = messageText;

    return request;
  }
}

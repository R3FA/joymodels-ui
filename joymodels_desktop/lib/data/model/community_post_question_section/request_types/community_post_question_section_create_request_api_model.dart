import 'package:http/http.dart' as http;

class CommunityPostQuestionSectionCreateRequestApiModel {
  final String communityPostUuid;
  final String messageText;

  CommunityPostQuestionSectionCreateRequestApiModel({
    required this.communityPostUuid,
    required this.messageText,
  });

  Future<http.MultipartRequest> toMultipartRequest(
    String method,
    Uri url,
  ) async {
    final request = http.MultipartRequest(method, url);

    request.fields['communityPostUuid'] = communityPostUuid;
    request.fields['messageText'] = messageText;

    return request;
  }
}

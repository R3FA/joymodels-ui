import 'package:http/http.dart' as http;

class CommunityPostReviewTypeCreateRequestApiModel {
  final String communityPostReviewTypeName;

  CommunityPostReviewTypeCreateRequestApiModel({
    required this.communityPostReviewTypeName,
  });

  Future<http.MultipartRequest> toMultipartRequest(Uri url) async {
    final request = http.MultipartRequest('POST', url);
    request.fields['CommunityPostReviewTypeName'] = communityPostReviewTypeName;
    return request;
  }
}

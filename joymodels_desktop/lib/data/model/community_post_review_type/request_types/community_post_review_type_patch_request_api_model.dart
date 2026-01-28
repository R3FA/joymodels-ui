import 'package:http/http.dart' as http;

class CommunityPostReviewTypePatchRequestApiModel {
  final String communityPostReviewTypeUuid;
  final String communityPostReviewTypeName;

  CommunityPostReviewTypePatchRequestApiModel({
    required this.communityPostReviewTypeUuid,
    required this.communityPostReviewTypeName,
  });

  Future<http.MultipartRequest> toMultipartRequest(Uri url) async {
    final request = http.MultipartRequest('PATCH', url);
    request.fields['CommunityPostReviewTypeUuid'] = communityPostReviewTypeUuid;
    request.fields['CommunityPostReviewTypeName'] = communityPostReviewTypeName;
    return request;
  }
}

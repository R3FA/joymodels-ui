import 'package:http/http.dart' as http;

class CommunityPostUserReviewCreateRequestApiModel {
  final String communityPostUuid;
  final String reviewTypeUuid;

  CommunityPostUserReviewCreateRequestApiModel({
    required this.communityPostUuid,
    required this.reviewTypeUuid,
  });

  Future<http.MultipartRequest> toMultipartRequest(
    String method,
    Uri url,
  ) async {
    final request = http.MultipartRequest(method, url);

    request.fields['communityPostUuid'] = communityPostUuid;
    request.fields['reviewTypeUuid'] = reviewTypeUuid;

    return request;
  }
}

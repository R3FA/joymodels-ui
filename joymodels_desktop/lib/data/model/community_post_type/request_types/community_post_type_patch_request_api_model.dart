import 'package:http/http.dart' as http;

class CommunityPostTypePatchRequestApiModel {
  final String postTypeUuid;
  final String postTypeName;

  CommunityPostTypePatchRequestApiModel({
    required this.postTypeUuid,
    required this.postTypeName,
  });

  Future<http.MultipartRequest> toMultipartRequest(Uri url) async {
    final request = http.MultipartRequest('PATCH', url);
    request.fields['PostTypeUuid'] = postTypeUuid;
    request.fields['PostTypeName'] = postTypeName;
    return request;
  }
}

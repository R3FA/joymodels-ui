import 'package:http/http.dart' as http;

class CommunityPostTypeCreateRequestApiModel {
  final String postTypeName;

  CommunityPostTypeCreateRequestApiModel({required this.postTypeName});

  Future<http.MultipartRequest> toMultipartRequest(Uri url) async {
    final request = http.MultipartRequest('POST', url);
    request.fields['PostTypeName'] = postTypeName;
    return request;
  }
}

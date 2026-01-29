import 'package:http/http.dart' as http;

class SsoAccessTokenChangeRequestApiModel {
  final String userUuid;
  final String userRefreshToken;

  SsoAccessTokenChangeRequestApiModel({
    required this.userUuid,
    required this.userRefreshToken,
  });

  Future<http.MultipartRequest> toMultipartRequest(Uri url) async {
    final multiPartRequest = http.MultipartRequest('POST', url);

    multiPartRequest.fields['UserUuid'] = userUuid;
    multiPartRequest.fields['UserRefreshToken'] = userRefreshToken;

    return multiPartRequest;
  }
}

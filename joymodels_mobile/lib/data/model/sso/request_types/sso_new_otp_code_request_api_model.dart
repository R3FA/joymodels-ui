import 'package:http/http.dart' as http;

class SsoNewOtpCodeRequestApiModel {
  final String userUuid;

  SsoNewOtpCodeRequestApiModel({required this.userUuid});

  Future<http.MultipartRequest> toMultipartRequest(Uri url) async {
    final multiPartRequest = http.MultipartRequest('POST', url);

    multiPartRequest.fields['UserUuid'] = userUuid;

    return multiPartRequest;
  }
}

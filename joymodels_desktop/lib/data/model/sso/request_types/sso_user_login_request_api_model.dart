import 'package:http/http.dart' as http;

class SsoUserLoginRequestApiModel {
  final String nickname;
  final String password;

  SsoUserLoginRequestApiModel({required this.nickname, required this.password});

  Future<http.MultipartRequest> toMultipartRequest(Uri url) async {
    final multiPartRequest = http.MultipartRequest('POST', url);

    multiPartRequest.fields['Nickname'] = nickname;
    multiPartRequest.fields['Password'] = password;

    return multiPartRequest;
  }
}

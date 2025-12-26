import 'package:http/http.dart' as http;

class SsoVerifyRequestApiModel {
  final String userUuid;
  final String otpCode;
  final String userRefreshToken;

  SsoVerifyRequestApiModel({
    required this.userUuid,
    required this.otpCode,
    required this.userRefreshToken,
  });

  Future<http.MultipartRequest> toMultipartRequest(Uri url) async {
    final multiPartRequest = http.MultipartRequest('POST', url);

    multiPartRequest.fields['UserUuid'] = userUuid;
    multiPartRequest.fields['OtpCode'] = otpCode;
    multiPartRequest.fields['UserRefreshToken'] = userRefreshToken;

    return multiPartRequest;
  }
}

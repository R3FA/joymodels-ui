import 'package:http/http.dart' as http;

class SsoPasswordChangeRequestApiModel {
  final String userUuid;
  final String newPassword;
  final String confirmNewPassword;

  SsoPasswordChangeRequestApiModel({
    required this.userUuid,
    required this.newPassword,
    required this.confirmNewPassword,
  });

  Future<http.MultipartRequest> toMultipartRequest(Uri url) async {
    final request = http.MultipartRequest('PATCH', url);

    request.fields['userUuid'] = userUuid;
    request.fields['newPassword'] = newPassword;
    request.fields['confirmNewPassword'] = confirmNewPassword;

    return request;
  }
}

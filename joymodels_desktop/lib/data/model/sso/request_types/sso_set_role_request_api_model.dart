import 'package:http/http.dart' as http;

class SsoSetRoleRequestApiModel {
  final String userUuid;
  final String designatedUserRoleUuid;

  SsoSetRoleRequestApiModel({
    required this.userUuid,
    required this.designatedUserRoleUuid,
  });

  Future<http.MultipartRequest> toMultipartRequest(Uri url) async {
    final request = http.MultipartRequest('PATCH', url);
    request.fields['UserUuid'] = userUuid;
    request.fields['DesignatedUserRoleUuid'] = designatedUserRoleUuid;
    return request;
  }
}

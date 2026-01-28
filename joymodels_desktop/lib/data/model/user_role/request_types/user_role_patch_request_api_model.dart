import 'package:http/http.dart' as http;

class UserRolePatchRequestApiModel {
  final String roleUuid;
  final String roleName;

  UserRolePatchRequestApiModel({
    required this.roleUuid,
    required this.roleName,
  });

  Future<http.MultipartRequest> toMultipartRequest(Uri url) async {
    final request = http.MultipartRequest('PATCH', url);
    request.fields['RoleUuid'] = roleUuid;
    request.fields['RoleName'] = roleName;
    return request;
  }
}

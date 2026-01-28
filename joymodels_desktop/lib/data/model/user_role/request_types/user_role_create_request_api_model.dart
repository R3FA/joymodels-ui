import 'package:http/http.dart' as http;

class UserRoleCreateRequestApiModel {
  final String roleName;

  UserRoleCreateRequestApiModel({required this.roleName});

  Future<http.MultipartRequest> toMultipartRequest(Uri url) async {
    final request = http.MultipartRequest('POST', url);
    request.fields['RoleName'] = roleName;
    return request;
  }
}

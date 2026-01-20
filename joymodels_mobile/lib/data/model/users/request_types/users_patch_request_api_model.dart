import 'package:http/http.dart' as http;

class UsersPatchRequestApiModel {
  final String userUuid;
  final String? firstName;
  final String? lastName;
  final String? nickname;
  final String? userPicturePath;

  UsersPatchRequestApiModel({
    required this.userUuid,
    this.firstName,
    this.lastName,
    this.nickname,
    this.userPicturePath,
  });

  Future<http.MultipartRequest> toMultipartRequest(
    String method,
    Uri url,
  ) async {
    final request = http.MultipartRequest(method, url);

    request.fields['userUuid'] = userUuid;
    if (firstName != null) request.fields['firstName'] = firstName!;
    if (lastName != null) request.fields['lastName'] = lastName!;
    if (nickname != null) request.fields['nickname'] = nickname!;

    if (userPicturePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath('userPicture', userPicturePath!),
      );
    }

    return request;
  }
}

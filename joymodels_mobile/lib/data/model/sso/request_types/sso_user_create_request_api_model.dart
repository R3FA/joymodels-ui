import 'dart:io';
import 'package:http/http.dart' as http;

class SsoUserCreateRequestApiModel {
  final String firstName;
  final String? lastName;
  final String nickname;
  final String email;
  final String password;
  final File userPicture;

  SsoUserCreateRequestApiModel({
    required this.firstName,
    this.lastName,
    required this.nickname,
    required this.email,
    required this.password,
    required this.userPicture,
  });

  Future<http.MultipartRequest> toMultipartRequest(Uri url) async {
    final multiPartRequest = http.MultipartRequest('POST', url);

    multiPartRequest.fields['FirstName'] = firstName;
    if (lastName != null && lastName!.isNotEmpty) {
      multiPartRequest.fields['LastName'] = lastName!;
    }
    multiPartRequest.fields['NickName'] = nickname;
    multiPartRequest.fields['Email'] = email;
    multiPartRequest.fields['Password'] = password;

    multiPartRequest.files.add(
      await http.MultipartFile.fromPath("UserPicture", userPicture.path),
    );

    return multiPartRequest;
  }
}

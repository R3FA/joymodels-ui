import 'dart:io';

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
}

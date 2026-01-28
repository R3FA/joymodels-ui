import 'package:joymodels_desktop/data/model/user_role/response_types/user_role_response_api_model.dart';

class SsoUserResponseApiModel {
  final String uuid;
  final String firstName;
  final String? lastName;
  final String nickName;
  final String email;
  final DateTime createdAt;
  final String userAccessToken;
  final String userPictureLocation;
  final UserRoleResponseApiModel userRole;

  SsoUserResponseApiModel({
    required this.uuid,
    required this.firstName,
    this.lastName,
    required this.nickName,
    required this.email,
    required this.createdAt,
    required this.userAccessToken,
    required this.userPictureLocation,
    required this.userRole,
  });

  factory SsoUserResponseApiModel.fromJson(Map<String, dynamic> json) {
    return SsoUserResponseApiModel(
      uuid: json['uuid'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      nickName: json['nickName'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userAccessToken: json['userAccessToken'] as String,
      userPictureLocation: json['userPictureLocation'] as String,
      userRole: UserRoleResponseApiModel.fromJson(json['userRole']),
    );
  }
}

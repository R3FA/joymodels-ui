import 'package:joymodels_mobile/domain/models/user_role/user_role_response.dart';

class SsoUserResponse {
  late final String uuid;
  late final String firstName;
  late final String? lastName;
  late final String nickname;
  late final String email;
  late final DateTime created;
  late final String? accessToken;
  late final String pictureUrl;
  final UserRoleResponse userRole;

  SsoUserResponse({
    required this.uuid,
    required this.firstName,
    this.lastName,
    required this.nickname,
    required this.email,
    required this.created,
    this.accessToken,
    required this.pictureUrl,
    required this.userRole,
  });
}

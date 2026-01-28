import 'package:joymodels_desktop/data/model/users/response_types/users_response_api_model.dart';

class UserFollowingResponseApiModel {
  final String uuid;
  final UsersResponseApiModel targetUser;
  final DateTime followedAt;

  UserFollowingResponseApiModel({
    required this.uuid,
    required this.targetUser,
    required this.followedAt,
  });

  factory UserFollowingResponseApiModel.fromJson(Map<String, dynamic> json) {
    return UserFollowingResponseApiModel(
      uuid: json['uuid'] as String,
      targetUser: UsersResponseApiModel.fromJson(json['targetUser']),
      followedAt: DateTime.parse(json['followedAt']),
    );
  }
}

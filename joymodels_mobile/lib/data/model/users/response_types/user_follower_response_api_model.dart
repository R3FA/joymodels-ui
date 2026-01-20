import 'package:joymodels_mobile/data/model/users/response_types/users_response_api_model.dart';

class UserFollowerResponseApiModel {
  final String uuid;
  final UsersResponseApiModel originUser;
  final DateTime followedAt;

  UserFollowerResponseApiModel({
    required this.uuid,
    required this.originUser,
    required this.followedAt,
  });

  factory UserFollowerResponseApiModel.fromJson(Map<String, dynamic> json) {
    return UserFollowerResponseApiModel(
      uuid: json['uuid'] as String,
      originUser: UsersResponseApiModel.fromJson(json['originUser']),
      followedAt: DateTime.parse(json['followedAt']),
    );
  }
}

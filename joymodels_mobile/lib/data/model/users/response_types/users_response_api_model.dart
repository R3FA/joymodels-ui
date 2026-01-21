import 'package:joymodels_mobile/data/model/user_role/response_types/user_role_response_api_model.dart';

class UsersResponseApiModel {
  final String uuid;
  final String firstName;
  final String? lastName;
  final String nickName;
  final String email;
  final DateTime createdAt;
  final String userPictureLocation;
  final int userFollowerCount;
  final int userFollowingCount;
  final int userLikedModelsCount;
  final int userModelsCount;
  final UserRoleResponseApiModel userRole;

  UsersResponseApiModel({
    required this.uuid,
    required this.firstName,
    this.lastName,
    required this.nickName,
    required this.email,
    required this.createdAt,
    required this.userPictureLocation,
    required this.userFollowerCount,
    required this.userFollowingCount,
    required this.userLikedModelsCount,
    required this.userModelsCount,
    required this.userRole,
  });

  factory UsersResponseApiModel.fromJson(Map<String, dynamic> json) {
    return UsersResponseApiModel(
      uuid: json['uuid'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String?,
      nickName: json['nickName'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      userPictureLocation: json['userPictureLocation'] as String,
      userFollowerCount: json['userFollowerCount'] as int,
      userFollowingCount: json['userFollowingCount'] as int,
      userLikedModelsCount: json['userLikedModelsCount'] as int,
      userModelsCount: json['userModelsCount'] as int,
      userRole: UserRoleResponseApiModel.fromJson(json['userRole']),
    );
  }

  UsersResponseApiModel copyWith({
    String? uuid,
    String? firstName,
    String? lastName,
    String? nickName,
    String? email,
    DateTime? createdAt,
    String? userPictureLocation,
    int? userFollowerCount,
    int? userFollowingCount,
    int? userLikedModelsCount,
    int? userModelsCount,
    UserRoleResponseApiModel? userRole,
  }) {
    return UsersResponseApiModel(
      uuid: uuid ?? this.uuid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      nickName: nickName ?? this.nickName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      userPictureLocation: userPictureLocation ?? this.userPictureLocation,
      userFollowerCount: userFollowerCount ?? this.userFollowerCount,
      userFollowingCount: userFollowingCount ?? this.userFollowingCount,
      userLikedModelsCount: userLikedModelsCount ?? this.userLikedModelsCount,
      userModelsCount: userModelsCount ?? this.userModelsCount,
      userRole: userRole ?? this.userRole,
    );
  }
}

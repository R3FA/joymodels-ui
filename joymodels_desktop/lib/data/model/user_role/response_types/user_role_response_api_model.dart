class UserRoleResponseApiModel {
  final String uuid;
  final String roleName;

  UserRoleResponseApiModel({required this.uuid, required this.roleName});

  factory UserRoleResponseApiModel.fromJson(Map<String, dynamic> json) {
    return UserRoleResponseApiModel(
      uuid: json["uuid"] as String,
      roleName: json["roleName"] as String,
    );
  }
}

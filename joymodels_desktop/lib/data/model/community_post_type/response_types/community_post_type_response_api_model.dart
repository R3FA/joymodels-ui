class CommunityPostTypeResponseApiModel {
  final String uuid;
  final String communityPostName;

  CommunityPostTypeResponseApiModel({
    required this.uuid,
    required this.communityPostName,
  });

  factory CommunityPostTypeResponseApiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CommunityPostTypeResponseApiModel(
      uuid: json['uuid'] as String,
      communityPostName: json['communityPostName'] as String,
    );
  }
}

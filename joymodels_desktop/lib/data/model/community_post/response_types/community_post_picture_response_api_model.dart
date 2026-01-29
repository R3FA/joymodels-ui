class CommunityPostPictureResponseApiModel {
  final String uuid;
  final String pictureLocation;
  final DateTime createdAt;

  CommunityPostPictureResponseApiModel({
    required this.uuid,
    required this.pictureLocation,
    required this.createdAt,
  });

  factory CommunityPostPictureResponseApiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CommunityPostPictureResponseApiModel(
      uuid: json['uuid'] as String,
      pictureLocation: json['pictureLocation'] as String,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

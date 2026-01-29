class ModelPictureResponseApiModel {
  final String uuid;
  final String modelUuid;
  final String pictureLocation;
  final DateTime createdAt;

  ModelPictureResponseApiModel({
    required this.uuid,
    required this.modelUuid,
    required this.pictureLocation,
    required this.createdAt,
  });

  factory ModelPictureResponseApiModel.fromJson(Map<String, dynamic> json) {
    return ModelPictureResponseApiModel(
      uuid: json['uuid'],
      modelUuid: json['modelUuid'],
      pictureLocation: json['pictureLocation'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

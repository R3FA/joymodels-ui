class ModelReviewTypeResponseApiModel {
  final String uuid;
  final String modelReviewTypeName;

  ModelReviewTypeResponseApiModel({
    required this.uuid,
    required this.modelReviewTypeName,
  });

  factory ModelReviewTypeResponseApiModel.fromJson(Map<String, dynamic> json) {
    return ModelReviewTypeResponseApiModel(
      uuid: json['uuid'],
      modelReviewTypeName: json['reviewType'],
    );
  }
}

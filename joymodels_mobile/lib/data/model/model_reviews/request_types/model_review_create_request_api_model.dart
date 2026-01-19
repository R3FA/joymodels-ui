class ModelReviewCreateRequestApiModel {
  final String modelUuid;
  final String modelReviewTypeUuid;
  final String modelReviewText;

  ModelReviewCreateRequestApiModel({
    required this.modelUuid,
    required this.modelReviewTypeUuid,
    required this.modelReviewText,
  });

  Map<String, String> toFormData() {
    return {
      'ModelUuid': modelUuid,
      'ModelReviewTypeUuid': modelReviewTypeUuid,
      'ModelReviewText': modelReviewText,
    };
  }
}

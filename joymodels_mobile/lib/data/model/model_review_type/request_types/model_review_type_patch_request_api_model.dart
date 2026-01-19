class ModelReviewTypePatchRequestApiModel {
  final String modelReviewTypeUuid;
  final String modelReviewTypeName;

  ModelReviewTypePatchRequestApiModel({
    required this.modelReviewTypeUuid,
    required this.modelReviewTypeName,
  });

  Map<String, String> toFormData() {
    return {
      'ModelReviewTypeUuid': modelReviewTypeUuid,
      'ModelReviewTypeName': modelReviewTypeName,
    };
  }
}

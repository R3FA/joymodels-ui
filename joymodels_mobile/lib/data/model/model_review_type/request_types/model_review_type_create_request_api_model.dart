class ModelReviewTypeCreateRequestApiModel {
  final String modelReviewTypeName;

  ModelReviewTypeCreateRequestApiModel({required this.modelReviewTypeName});

  Map<String, String> toFormData() {
    return {'ModelReviewTypeName': modelReviewTypeName};
  }
}

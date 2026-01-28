class ModelReviewPatchRequestApiModel {
  final String modelReviewUuid;
  final String? modelReviewTypeUuid;
  final String? modelReviewText;

  ModelReviewPatchRequestApiModel({
    required this.modelReviewUuid,
    this.modelReviewTypeUuid,
    this.modelReviewText,
  });

  Map<String, String> toFormData() {
    final Map<String, String> data = {'ModelReviewUuid': modelReviewUuid};

    if (modelReviewTypeUuid != null) {
      data['ModelReviewTypeUuid'] = modelReviewTypeUuid!;
    }

    if (modelReviewText != null) {
      data['ModelReviewText'] = modelReviewText!;
    }

    return data;
  }
}

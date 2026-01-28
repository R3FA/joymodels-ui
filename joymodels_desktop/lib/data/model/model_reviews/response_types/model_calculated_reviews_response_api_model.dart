class ModelCalculatedReviewsResponseApiModel {
  final String reviewPercentage;
  final String modelReviewResponse;

  ModelCalculatedReviewsResponseApiModel({
    required this.reviewPercentage,
    required this.modelReviewResponse,
  });

  factory ModelCalculatedReviewsResponseApiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ModelCalculatedReviewsResponseApiModel(
      reviewPercentage: json['reviewPercentage'] as String? ?? '',
      modelReviewResponse: json['modelReviewResponse'] as String? ?? '',
    );
  }
}

class CommunityPostReviewTypeResponseApiModel {
  final String uuid;
  final String reviewName;

  CommunityPostReviewTypeResponseApiModel({
    required this.uuid,
    required this.reviewName,
  });

  factory CommunityPostReviewTypeResponseApiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CommunityPostReviewTypeResponseApiModel(
      uuid: json['uuid'] as String,
      reviewName: json['reviewName'] as String,
    );
  }
}

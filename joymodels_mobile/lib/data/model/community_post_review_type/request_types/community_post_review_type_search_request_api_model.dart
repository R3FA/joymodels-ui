class CommunityPostReviewTypeSearchRequestApiModel {
  final String? communityPostReviewTypeName;
  final int pageNumber;
  final int pageSize;

  CommunityPostReviewTypeSearchRequestApiModel({
    this.communityPostReviewTypeName,
    required this.pageNumber,
    required this.pageSize,
  });

  Map<String, String> toQueryParameters() {
    final Map<String, String> params = {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
    };

    if (communityPostReviewTypeName != null &&
        communityPostReviewTypeName!.isNotEmpty) {
      params['communityPostReviewTypeName'] = communityPostReviewTypeName!;
    }

    return params;
  }
}

class CommunityPostTypeSearchRequestApiModel {
  final String? postTypeName;
  final int pageNumber;
  final int pageSize;

  CommunityPostTypeSearchRequestApiModel({
    this.postTypeName,
    required this.pageNumber,
    required this.pageSize,
  });

  Map<String, String> toQueryParameters() {
    final Map<String, String> params = {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
    };

    if (postTypeName != null && postTypeName!.isNotEmpty) {
      params['postTypeName'] = postTypeName!;
    }

    return params;
  }
}

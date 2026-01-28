import 'package:joymodels_desktop/data/model/pagination/request_types/pagination_request_api_model.dart';

class CommunityPostReviewTypeSearchRequestApiModel
    extends PaginationRequestApiModel {
  final String? communityPostReviewTypeName;

  CommunityPostReviewTypeSearchRequestApiModel({
    this.communityPostReviewTypeName,
    required super.pageNumber,
    required super.pageSize,
    super.orderBy,
  });

  @override
  Map<String, String> toQueryParameters() {
    return {
      ...super.toQueryParameters(),
      if (communityPostReviewTypeName != null &&
          communityPostReviewTypeName!.isNotEmpty)
        'communityPostReviewTypeName': communityPostReviewTypeName!,
    };
  }
}

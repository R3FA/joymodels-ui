import 'package:joymodels_desktop/data/model/enums/model_review_enum.dart';
import 'package:joymodels_desktop/data/model/pagination/request_types/pagination_request_api_model.dart';

class CommunityPostSearchReviewedUsersRequestApiModel
    extends PaginationRequestApiModel {
  final String communityPostUuid;
  final ModelReviewEnum communityPostReviewType;

  CommunityPostSearchReviewedUsersRequestApiModel({
    required this.communityPostUuid,
    required this.communityPostReviewType,
    required super.pageNumber,
    required super.pageSize,
  });

  @override
  Map<String, String> toQueryParameters() {
    return {
      ...super.toQueryParameters(),
      'communityPostUuid': communityPostUuid,
      'communityPostReviewType': communityPostReviewType.value.toString(),
    };
  }
}

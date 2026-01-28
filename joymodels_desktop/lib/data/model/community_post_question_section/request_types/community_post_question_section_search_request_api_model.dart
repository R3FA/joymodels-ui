import 'package:joymodels_desktop/data/model/pagination/request_types/pagination_request_api_model.dart';

class CommunityPostQuestionSectionSearchRequestApiModel
    extends PaginationRequestApiModel {
  final String communityPostUuid;

  CommunityPostQuestionSectionSearchRequestApiModel({
    required this.communityPostUuid,
    required super.pageNumber,
    required super.pageSize,
    super.orderBy,
  });

  @override
  Map<String, String> toQueryParameters() {
    return {
      ...super.toQueryParameters(),
      'communityPostUuid': communityPostUuid,
    };
  }
}

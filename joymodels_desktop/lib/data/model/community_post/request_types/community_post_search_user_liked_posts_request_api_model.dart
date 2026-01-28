import 'package:joymodels_desktop/data/model/pagination/request_types/pagination_request_api_model.dart';

class CommunityPostSearchUserLikedPostsRequestApiModel
    extends PaginationRequestApiModel {
  final String userUuid;

  CommunityPostSearchUserLikedPostsRequestApiModel({
    required this.userUuid,
    required super.pageNumber,
    required super.pageSize,
  });

  @override
  Map<String, String> toQueryParameters() {
    return {...super.toQueryParameters(), 'userUuid': userUuid};
  }
}

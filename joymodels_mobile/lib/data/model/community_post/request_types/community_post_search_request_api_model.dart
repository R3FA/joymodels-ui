import 'package:joymodels_mobile/data/model/pagination/request_types/pagination_request_api_model.dart';

class CommunityPostSearchRequestApiModel extends PaginationRequestApiModel {
  final String? title;
  final String? postTypeUuid;

  CommunityPostSearchRequestApiModel({
    this.title,
    this.postTypeUuid,
    required super.pageNumber,
    required super.pageSize,
  });

  @override
  Map<String, String> toQueryParameters() {
    return {
      ...super.toQueryParameters(),
      if (title != null) 'title': title!,
      if (postTypeUuid != null) 'postTypeUuid': postTypeUuid!,
    };
  }
}

import 'package:joymodels_mobile/data/model/pagination/request_types/pagination_request_api_model.dart';

class CommunityPostSearchRequestApiModel extends PaginationRequestApiModel {
  final String? title;
  final String? userUuid;

  CommunityPostSearchRequestApiModel({
    this.title,
    this.userUuid,
    required super.pageNumber,
    required super.pageSize,
    super.orderBy,
  });

  @override
  Map<String, String> toQueryParameters() {
    return {
      ...super.toQueryParameters(),
      if (title != null) 'title': title!,
      if (userUuid != null) 'userUuid': userUuid!,
    };
  }
}

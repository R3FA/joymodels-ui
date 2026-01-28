import 'package:joymodels_desktop/data/model/pagination/request_types/pagination_request_api_model.dart';

class CommunityPostTypeSearchRequestApiModel extends PaginationRequestApiModel {
  final String? postTypeName;

  CommunityPostTypeSearchRequestApiModel({
    this.postTypeName,
    required super.pageNumber,
    required super.pageSize,
    super.orderBy,
  });

  @override
  Map<String, String> toQueryParameters() {
    return {
      ...super.toQueryParameters(),
      if (postTypeName != null && postTypeName!.isNotEmpty)
        'postTypeName': postTypeName!,
    };
  }
}

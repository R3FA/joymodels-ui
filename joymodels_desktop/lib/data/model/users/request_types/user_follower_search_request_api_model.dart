import 'package:joymodels_desktop/data/model/pagination/request_types/pagination_request_api_model.dart';

class UserFollowerSearchRequestApiModel extends PaginationRequestApiModel {
  final String targetUserUuid;
  final String? nickname;

  UserFollowerSearchRequestApiModel({
    required this.targetUserUuid,
    this.nickname,
    required super.pageNumber,
    required super.pageSize,
  });

  @override
  Map<String, String> toQueryParameters() {
    return {
      ...super.toQueryParameters(),
      'targetUserUuid': targetUserUuid,
      if (nickname != null) 'nickname': nickname!,
    };
  }
}

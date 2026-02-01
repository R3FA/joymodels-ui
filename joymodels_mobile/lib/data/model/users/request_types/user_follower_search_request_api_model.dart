import 'package:joymodels_mobile/data/model/pagination/request_types/pagination_request_api_model.dart';

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
      'nickname': ?nickname,
    };
  }
}

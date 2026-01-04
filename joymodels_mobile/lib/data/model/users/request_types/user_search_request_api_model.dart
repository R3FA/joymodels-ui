import 'package:joymodels_mobile/data/model/pagination/request_types/pagination_request_api_model.dart';

class UsersSearchRequestApiModel extends PaginationRequestApiModel {
  final String? nickname;

  UsersSearchRequestApiModel({
    this.nickname,
    required super.pageNumber,
    required super.pageSize,
  });

  Map<String, String> toQueryParameters() {
    return {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      if (nickname != null) 'nickname': nickname!,
    };
  }
}

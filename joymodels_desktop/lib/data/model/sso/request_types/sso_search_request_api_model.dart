import 'package:joymodels_desktop/data/model/pagination/request_types/pagination_request_api_model.dart';

class SsoSearchRequestApiModel extends PaginationRequestApiModel {
  final String? nickname;
  final String? email;

  SsoSearchRequestApiModel({
    this.nickname,
    this.email,
    super.pageNumber,
    super.pageSize,
    super.orderBy,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (nickname != null && nickname!.isNotEmpty) json['nickname'] = nickname!;
    if (email != null && email!.isNotEmpty) json['email'] = email!;
    return json;
  }

  @override
  Map<String, String> toQueryParameters() {
    final params = super.toQueryParameters();
    if (nickname != null && nickname!.isNotEmpty) {
      params['nickname'] = nickname!;
    }
    if (email != null && email!.isNotEmpty) {
      params['email'] = email!;
    }
    return params;
  }
}

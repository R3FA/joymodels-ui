import 'package:joymodels_desktop/data/model/pagination/request_types/pagination_request_api_model.dart';

class UserRoleSearchRequestApiModel extends PaginationRequestApiModel {
  final String? roleName;

  UserRoleSearchRequestApiModel({
    this.roleName,
    super.pageNumber,
    super.pageSize,
    super.orderBy,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (roleName != null && roleName!.isNotEmpty) {
      json['roleName'] = roleName!;
    }
    return json;
  }

  @override
  Map<String, String> toQueryParameters() {
    final params = super.toQueryParameters();
    if (roleName != null && roleName!.isNotEmpty) {
      params['roleName'] = roleName!;
    }
    return params;
  }
}

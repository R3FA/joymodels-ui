import 'package:joymodels_mobile/data/model/pagination/request_types/pagination_request_api_model.dart';

class OrderSearchRequestApiModel extends PaginationRequestApiModel {
  final String? status;

  OrderSearchRequestApiModel({
    this.status,
    super.pageNumber,
    super.pageSize,
    super.orderBy,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();

    if (status != null && status!.isNotEmpty) {
      json['status'] = status;
    }

    return json;
  }

  @override
  Map<String, String> toQueryParameters() {
    final params = super.toQueryParameters();

    if (status != null && status!.isNotEmpty) {
      params['status'] = status!;
    }

    return params;
  }
}

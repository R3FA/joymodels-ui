import 'package:joymodels_desktop/data/model/pagination/request_types/pagination_request_api_model.dart';

class OrderAdminSearchRequestApiModel extends PaginationRequestApiModel {
  final String? userUuid;
  final String? status;
  final String? stripePaymentIntentId;

  OrderAdminSearchRequestApiModel({
    this.userUuid,
    this.status,
    this.stripePaymentIntentId,
    super.pageNumber,
    super.pageSize,
    super.orderBy,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    if (userUuid != null) json['userUuid'] = userUuid!;
    if (status != null && status!.isNotEmpty) json['status'] = status!;
    if (stripePaymentIntentId != null && stripePaymentIntentId!.isNotEmpty) {
      json['stripePaymentIntentId'] = stripePaymentIntentId!;
    }
    return json;
  }

  @override
  Map<String, String> toQueryParameters() {
    final params = super.toQueryParameters();
    if (userUuid != null) params['userUuid'] = userUuid!;
    if (status != null && status!.isNotEmpty) params['status'] = status!;
    if (stripePaymentIntentId != null && stripePaymentIntentId!.isNotEmpty) {
      params['stripePaymentIntentId'] = stripePaymentIntentId!;
    }
    return params;
  }
}

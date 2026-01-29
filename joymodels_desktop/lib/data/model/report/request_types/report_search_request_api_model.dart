import 'package:joymodels_desktop/data/model/pagination/request_types/pagination_request_api_model.dart';

class ReportSearchRequestApiModel extends PaginationRequestApiModel {
  final String? status;
  final String? reportedEntityType;
  final String? reason;

  ReportSearchRequestApiModel({
    this.status,
    this.reportedEntityType,
    this.reason,
    super.pageNumber,
    super.pageSize,
    super.orderBy,
  });

  @override
  Map<String, String> toQueryParameters() {
    return {
      ...super.toQueryParameters(),
      if (status != null && status!.isNotEmpty) 'status': status!,
      if (reportedEntityType != null && reportedEntityType!.isNotEmpty)
        'reportedEntityType': reportedEntityType!,
      if (reason != null && reason!.isNotEmpty) 'reason': reason!,
    };
  }
}

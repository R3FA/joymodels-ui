import 'package:joymodels_desktop/data/model/pagination/request_types/pagination_request_api_model.dart';

class NotificationSearchRequestApiModel extends PaginationRequestApiModel {
  final bool? isRead;
  final String? notificationType;

  NotificationSearchRequestApiModel({
    this.isRead,
    this.notificationType,
    super.pageNumber,
    super.pageSize,
    super.orderBy,
  });

  @override
  Map<String, String> toQueryParameters() {
    return {
      ...super.toQueryParameters(),
      if (isRead != null) 'isRead': isRead.toString(),
      if (notificationType != null && notificationType!.isNotEmpty)
        'notificationType': notificationType!,
    };
  }
}

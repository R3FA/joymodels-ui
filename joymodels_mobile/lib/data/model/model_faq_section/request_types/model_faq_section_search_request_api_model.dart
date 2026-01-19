import 'package:joymodels_mobile/data/model/pagination/request_types/pagination_request_api_model.dart';

class ModelFaqSectionSearchRequestApiModel extends PaginationRequestApiModel {
  final String modelUuid;
  final String? faqMessage;

  ModelFaqSectionSearchRequestApiModel({
    required this.modelUuid,
    this.faqMessage,
    super.pageNumber,
    super.pageSize,
    super.orderBy,
  });

  @override
  Map<String, String> toQueryParameters() {
    return {
      ...super.toQueryParameters(),
      'modelUuid': modelUuid,
      if (faqMessage != null) 'faqMessage': faqMessage!,
    };
  }
}

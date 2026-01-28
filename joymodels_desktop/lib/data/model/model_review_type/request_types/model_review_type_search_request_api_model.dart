import 'package:joymodels_desktop/data/model/pagination/request_types/pagination_request_api_model.dart';

class ModelReviewTypeSearchRequestApiModel extends PaginationRequestApiModel {
  final String? modelReviewTypeName;

  ModelReviewTypeSearchRequestApiModel({
    this.modelReviewTypeName,
    super.pageNumber,
    super.pageSize,
    super.orderBy,
  });

  @override
  Map<String, String> toQueryParameters() {
    return {
      ...super.toQueryParameters(),
      if (modelReviewTypeName != null && modelReviewTypeName!.isNotEmpty)
        'modelReviewTypeName': modelReviewTypeName!,
    };
  }
}

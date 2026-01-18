import 'package:joymodels_mobile/data/model/enums/model_review_enum.dart';
import 'package:joymodels_mobile/data/model/pagination/request_types/pagination_request_api_model.dart';

class ModelReviewSearchRequestApiModel extends PaginationRequestApiModel {
  final String modelUuid;
  final ModelReviewEnum modelReviewType;

  ModelReviewSearchRequestApiModel({
    required this.modelUuid,
    this.modelReviewType = ModelReviewEnum.all,
    super.pageNumber = 1,
    super.pageSize = 10,
    super.orderBy,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['modelUuid'] = modelUuid;
    json['modelReviewType'] = modelReviewType.value;
    return json;
  }

  @override
  Map<String, String> toQueryParameters() {
    final params = super.toQueryParameters();
    params['modelUuid'] = modelUuid;
    params['modelReviewType'] = modelReviewType.value.toString();
    return params;
  }
}

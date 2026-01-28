import 'package:joymodels_desktop/data/model/pagination/request_types/pagination_request_api_model.dart';

class ModelRecommendedRequestApiModel extends PaginationRequestApiModel {
  final String? modelName;

  ModelRecommendedRequestApiModel({
    super.pageNumber = 1,
    super.pageSize = 10,
    this.modelName,
  });

  @override
  Map<String, String> toQueryParameters() {
    return {
      ...super.toQueryParameters(),
      if (modelName != null && modelName!.isNotEmpty) 'modelName': modelName!,
    };
  }
}

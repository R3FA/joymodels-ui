import 'package:joymodels_mobile/data/model/pagination/request_types/pagination_request_api_model.dart';

class ModelSearchRequestApiModel extends PaginationRequestApiModel {
  final String? modelName;
  final String? categoryName;
  final bool arePrivateUserModelsSearched;

  ModelSearchRequestApiModel({
    this.modelName,
    this.categoryName,
    this.arePrivateUserModelsSearched = false,
    required super.pageNumber,
    required super.pageSize,
    super.orderBy,
  });

  @override
  Map<String, String> toQueryParameters() {
    return {
      ...super.toQueryParameters(),
      if (modelName != null) 'modelName': modelName!,
      if (categoryName != null) 'categoryName': categoryName!,
      'arePrivateUserModelsSearched': arePrivateUserModelsSearched.toString(),
    };
  }
}

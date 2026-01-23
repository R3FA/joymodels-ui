import 'package:joymodels_mobile/data/model/pagination/request_types/pagination_request_api_model.dart';

class LibrarySearchRequestApiModel extends PaginationRequestApiModel {
  final String? modelName;

  LibrarySearchRequestApiModel({
    this.modelName,
    super.pageNumber,
    super.pageSize,
    super.orderBy,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();

    if (modelName != null && modelName!.isNotEmpty) {
      json['modelName'] = modelName;
    }

    return json;
  }

  @override
  Map<String, String> toQueryParameters() {
    final params = super.toQueryParameters();

    if (modelName != null && modelName!.isNotEmpty) {
      params['modelName'] = modelName!;
    }

    return params;
  }
}

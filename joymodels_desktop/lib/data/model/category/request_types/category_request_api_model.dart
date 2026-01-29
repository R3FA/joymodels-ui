import 'package:joymodels_desktop/data/model/pagination/request_types/pagination_request_api_model.dart';

class CategorySearchRequestApiModel extends PaginationRequestApiModel {
  String? categoryName;

  CategorySearchRequestApiModel({
    super.pageNumber,
    super.pageSize,
    super.orderBy,
    this.categoryName,
  });

  @override
  Map<String, dynamic> toJson() {
    final map = super.toJson();
    if (categoryName != null) {
      map['categoryName'] = categoryName;
    }
    return map;
  }
}

import 'dart:convert';
import 'package:joymodels_mobile/data/model/category/request_types/category_request_api_model.dart';
import 'package:joymodels_mobile/data/model/category/response_types/category_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/services/category_service.dart';

class CategoryRepository {
  final CategoryService _service;

  CategoryRepository(this._service);

  Future<PaginationResponseApiModel<CategoryResponseApiModel>> search(
    CategorySearchRequestApiModel request,
  ) async {
    final response = await _service.search(request);

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel<CategoryResponseApiModel>.fromJson(
        jsonMap,
        (item) => CategoryResponseApiModel.fromJson(item),
      );
    } else {
      throw Exception(
        'Failed to fetch categories: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

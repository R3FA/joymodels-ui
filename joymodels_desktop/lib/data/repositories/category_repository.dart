import 'dart:convert';
import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/model/category/request_types/category_create_request_api_model.dart';
import 'package:joymodels_desktop/data/model/category/request_types/category_patch_request_api_model.dart';
import 'package:joymodels_desktop/data/model/category/request_types/category_request_api_model.dart';
import 'package:joymodels_desktop/data/model/category/response_types/category_response_api_model.dart';
import 'package:joymodels_desktop/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_desktop/data/services/category_service.dart';

class CategoryRepository {
  final CategoryService _service;
  final AuthService _authService;

  CategoryRepository(this._service, this._authService);

  Future<PaginationResponseApiModel<CategoryResponseApiModel>> search(
    CategorySearchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.search(request));

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

  Future<CategoryResponseApiModel> create(
    CategoryCreateRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.create(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return CategoryResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to create category: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<CategoryResponseApiModel> patch(
    CategoryPatchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.patch(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return CategoryResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to update category: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> delete(String categoryUuid) async {
    final response = await _authService.request(
      () => _service.delete(categoryUuid),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete category: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

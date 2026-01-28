import 'dart:convert';
import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_desktop/data/model/shopping_cart/request_types/shopping_cart_item_add_request_api_model.dart';
import 'package:joymodels_desktop/data/model/shopping_cart/request_types/shopping_cart_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/shopping_cart/response_types/shopping_cart_item_response_api_model.dart';
import 'package:joymodels_desktop/data/services/shopping_cart_service.dart';

class ShoppingCartRepository {
  final ShoppingCartService _service;
  final AuthService _authService;

  ShoppingCartRepository(this._service, this._authService);

  Future<ShoppingCartItemResponseApiModel?> getByUuid(String modelUuid) async {
    final response = await _authService.request(
      () => _service.getByUuid(modelUuid),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return ShoppingCartItemResponseApiModel.fromJson(jsonMap);
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception(
        'Failed to fetch shopping cart item by model uuid: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PaginationResponseApiModel<ShoppingCartItemResponseApiModel>> search(
    ShoppingCartSearchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.search(request));

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == 'null') {
        return PaginationResponseApiModel<ShoppingCartItemResponseApiModel>(
          data: [],
          pageNumber: 1,
          pageSize: request.pageSize,
          totalPages: 0,
          totalRecords: 0,
          hasPreviousPage: false,
          hasNextPage: false,
          orderBy: request.orderBy,
        );
      }

      try {
        final decoded = jsonDecode(response.body);
        if (decoded == null) {
          return PaginationResponseApiModel<ShoppingCartItemResponseApiModel>(
            data: [],
            pageNumber: 1,
            pageSize: request.pageSize,
            totalPages: 0,
            totalRecords: 0,
            hasPreviousPage: false,
            hasNextPage: false,
            orderBy: request.orderBy,
          );
        }

        final jsonMap = decoded as Map<String, dynamic>;
        return PaginationResponseApiModel.fromJson(
          jsonMap,
          (json) => ShoppingCartItemResponseApiModel.fromJson(json),
        );
      } catch (e) {
        throw Exception(
          'Failed to parse shopping cart response: $e\nBody: ${response.body}',
        );
      }
    } else {
      throw Exception(
        'Failed to fetch shopping cart items: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<ShoppingCartItemResponseApiModel?> create(
    ShoppingCartItemAddRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.create(request));

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isEmpty) {
        throw Exception(
          'Shopping cart created but no data returned from server',
        );
      }
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return ShoppingCartItemResponseApiModel.fromJson(jsonMap);
    } else if (response.statusCode == 404) {
      if (response.body.contains('Duplicate entry') ||
          response.body.contains('uq_user_model') ||
          response.body.contains('does not exist')) {
        return null;
      }
      throw Exception('Not found: ${response.body}');
    } else if (response.statusCode == 500) {
      if (response.body.contains('Duplicate entry') ||
          response.body.contains('uq_user_model')) {
        return null;
      }
      throw Exception('Server error: ${response.body}');
    } else {
      throw Exception(
        'Failed to add item to shopping cart: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> delete(String modelUuid) async {
    final response = await _authService.request(
      () => _service.delete(modelUuid),
    );

    if (response.statusCode == 204) {
      return;
    } else {
      throw Exception(
        'Failed to remove item from shopping cart: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

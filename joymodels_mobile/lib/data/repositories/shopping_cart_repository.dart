import 'dart:convert';
import 'package:joymodels_mobile/data/core/services/auth_service.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/model/shopping_cart/request_types/shopping_cart_item_add_request_api_model.dart';
import 'package:joymodels_mobile/data/model/shopping_cart/request_types/shopping_cart_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/shopping_cart/response_types/shopping_cart_item_response_api_model.dart';
import 'package:joymodels_mobile/data/services/shopping_cart_service.dart';

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
    } else {
      throw Exception(
        'Failed to fetch shopping cart item: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PaginationResponseApiModel<ShoppingCartItemResponseApiModel>> search(
    ShoppingCartSearchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.search(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel.fromJson(
        jsonMap,
        (json) => ShoppingCartItemResponseApiModel.fromJson(json),
      );
    } else {
      throw Exception(
        'Failed to fetch shopping cart items: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<bool> isModelInCart(String modelUuid) async {
    final response = await _authService.request(
      () => _service.isModelInCart(modelUuid),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception(
        'Failed to check if model is in cart: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<ShoppingCartItemResponseApiModel?> create(
    ShoppingCartItemAddRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.create(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return ShoppingCartItemResponseApiModel.fromJson(jsonMap);
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

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to remove item from shopping cart: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

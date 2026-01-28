import 'package:http/http.dart' as http;
import 'package:joymodels_desktop/data/core/config/api_constants.dart';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';
import 'package:joymodels_desktop/data/model/shopping_cart/request_types/shopping_cart_item_add_request_api_model.dart';
import 'package:joymodels_desktop/data/model/shopping_cart/request_types/shopping_cart_search_request_api_model.dart';

class ShoppingCartService {
  final String shoppingCartUrl = "${ApiConstants.baseUrl}/shopping-cart";

  Future<http.Response> getByUuid(String modelUuid) async {
    final url = Uri.parse("$shoppingCartUrl/get/$modelUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> search(
    ShoppingCartSearchRequestApiModel request,
  ) async {
    final queryParams = request.toQueryParameters();
    final uri = Uri.parse(
      "$shoppingCartUrl/search",
    ).replace(queryParameters: queryParams);
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> create(
    ShoppingCartItemAddRequestApiModel request,
  ) async {
    final url = Uri.parse("$shoppingCartUrl/create");
    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      body: request.toFormData(),
    );

    return response;
  }

  Future<http.Response> delete(String modelUuid) async {
    final url = Uri.parse("$shoppingCartUrl/delete/$modelUuid");
    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }
}

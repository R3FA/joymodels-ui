import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/model/order/request_types/order_search_request_api_model.dart';

class OrderService {
  final String orderUrl = "${ApiConstants.baseUrl}/orders";

  Future<http.Response> checkout() async {
    final url = Uri.parse("$orderUrl/checkout");
    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> getByUuid(String orderUuid) async {
    final url = Uri.parse("$orderUrl/get/$orderUuid");
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> search(OrderSearchRequestApiModel request) async {
    final queryParams = request.toQueryParameters();
    final uri = Uri.parse(
      "$orderUrl/search",
    ).replace(queryParameters: queryParams);
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> confirm(String paymentIntentId) async {
    final url = Uri.parse("$orderUrl/confirm/$paymentIntentId");
    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }
}

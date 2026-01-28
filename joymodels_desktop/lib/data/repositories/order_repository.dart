import 'dart:convert';
import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/model/order/request_types/order_admin_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/order/request_types/order_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/order/response_types/order_checkout_response_api_model.dart';
import 'package:joymodels_desktop/data/model/order/response_types/order_confirm_response_api_model.dart';
import 'package:joymodels_desktop/data/model/order/response_types/order_response_api_model.dart';
import 'package:joymodels_desktop/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_desktop/data/services/order_service.dart';

class OrderRepository {
  final OrderService _service;
  final AuthService _authService;

  OrderRepository(this._service, this._authService);

  Future<OrderCheckoutResponseApiModel> checkout() async {
    final response = await _authService.request(() => _service.checkout());

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return OrderCheckoutResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to create checkout: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<OrderResponseApiModel> getByUuid(String orderUuid) async {
    final response = await _authService.request(
      () => _service.getByUuid(orderUuid),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return OrderResponseApiModel.fromJson(jsonMap);
    } else if (response.statusCode == 404) {
      throw Exception('Order not found');
    } else {
      throw Exception(
        'Failed to fetch order: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PaginationResponseApiModel<OrderResponseApiModel>> search(
    OrderSearchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.search(request));

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == 'null') {
        return PaginationResponseApiModel<OrderResponseApiModel>(
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
          return PaginationResponseApiModel<OrderResponseApiModel>(
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
          (json) => OrderResponseApiModel.fromJson(json),
        );
      } catch (e) {
        throw Exception(
          'Failed to parse orders response: $e\nBody: ${response.body}',
        );
      }
    } else {
      throw Exception(
        'Failed to fetch orders: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<OrderConfirmResponseApiModel> confirm(String paymentIntentId) async {
    final response = await _authService.request(
      () => _service.confirm(paymentIntentId),
    );

    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    return OrderConfirmResponseApiModel.fromJson(jsonMap);
  }

  Future<PaginationResponseApiModel<OrderResponseApiModel>> adminSearch(
    OrderAdminSearchRequestApiModel request,
  ) async {
    final response = await _authService.request(
      () => _service.adminSearch(request),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel<OrderResponseApiModel>.fromJson(
        jsonMap,
        (item) => OrderResponseApiModel.fromJson(item),
      );
    } else {
      throw Exception(
        'Failed to admin search orders: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

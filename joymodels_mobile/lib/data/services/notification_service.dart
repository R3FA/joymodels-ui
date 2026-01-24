import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/model/notification/request_types/notification_search_request_api_model.dart';

class NotificationService {
  final String notificationUrl = "${ApiConstants.baseUrl}/notifications";

  Future<http.Response> getByUuid(String notificationUuid) async {
    final url = Uri.parse("$notificationUrl/get/$notificationUuid");
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> search(
    NotificationSearchRequestApiModel request,
  ) async {
    final queryParams = request.toQueryParameters();
    final uri = Uri.parse(
      "$notificationUrl/search",
    ).replace(queryParameters: queryParams);
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> getUnreadCount() async {
    final url = Uri.parse("$notificationUrl/unread-count");
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> markAsRead(String notificationUuid) async {
    final url = Uri.parse("$notificationUrl/mark-as-read/$notificationUuid");
    final token = await TokenStorage.getAccessToken();

    final response = await http.patch(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> markAllAsRead() async {
    final url = Uri.parse("$notificationUrl/mark-all-as-read");
    final token = await TokenStorage.getAccessToken();

    final response = await http.patch(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> delete(String notificationUuid) async {
    final url = Uri.parse("$notificationUrl/delete/$notificationUuid");
    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }
}

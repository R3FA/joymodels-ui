import 'dart:convert';
import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/model/notification/request_types/notification_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/notification/response_types/notification_response_api_model.dart';
import 'package:joymodels_desktop/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_desktop/data/services/notification_service.dart';

class NotificationRepository {
  final NotificationService _service;
  final AuthService _authService;

  NotificationRepository(this._service, this._authService);

  Future<NotificationResponseApiModel> getByUuid(
    String notificationUuid,
  ) async {
    final response = await _authService.request(
      () => _service.getByUuid(notificationUuid),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return NotificationResponseApiModel.fromJson(jsonMap);
    } else if (response.statusCode == 404) {
      throw Exception('Notification not found');
    } else {
      throw Exception(
        'Failed to fetch notification: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PaginationResponseApiModel<NotificationResponseApiModel>> search(
    NotificationSearchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.search(request));

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == 'null') {
        return PaginationResponseApiModel<NotificationResponseApiModel>(
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
          return PaginationResponseApiModel<NotificationResponseApiModel>(
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
          (json) => NotificationResponseApiModel.fromJson(json),
        );
      } catch (e) {
        throw Exception(
          'Failed to parse notifications response: $e\nBody: ${response.body}',
        );
      }
    } else {
      throw Exception(
        'Failed to fetch notifications: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<int> getUnreadCount() async {
    final response = await _authService.request(
      () => _service.getUnreadCount(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as int;
    } else {
      throw Exception(
        'Failed to fetch unread count: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> markAsRead(String notificationUuid) async {
    final response = await _authService.request(
      () => _service.markAsRead(notificationUuid),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to mark notification as read: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> markAllAsRead() async {
    final response = await _authService.request(() => _service.markAllAsRead());

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to mark all notifications as read: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> delete(String notificationUuid) async {
    final response = await _authService.request(
      () => _service.delete(notificationUuid),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete notification: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

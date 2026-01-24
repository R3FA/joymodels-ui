import 'dart:async';
import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/notification/request_types/notification_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/notification/response_types/notification_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/notification_repository.dart';
import 'package:joymodels_mobile/ui/core/mixins/pagination_mixin.dart';

class NotificationPageViewModel extends ChangeNotifier
    with PaginationMixin<NotificationResponseApiModel> {
  final _notificationRepository = sl<NotificationRepository>();

  bool isLoading = false;
  String? errorMessage;
  int unreadCount = 0;

  PaginationResponseApiModel<NotificationResponseApiModel>?
  notificationPagination;
  List<NotificationResponseApiModel> get notificationItems =>
      notificationPagination?.data ?? [];

  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;

  static const int _pageSize = 15;

  @override
  PaginationResponseApiModel<NotificationResponseApiModel>?
  get paginationData => notificationPagination;

  @override
  bool get isLoadingPage => isLoading;

  @override
  Future<void> loadPage(int pageNumber) async {
    await loadNotifications(pageNumber: pageNumber);
  }

  Future<void> init() async {
    await loadNotifications();
    await fetchUnreadCount();
  }

  Future<bool> loadNotifications({int? pageNumber}) async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      final request = NotificationSearchRequestApiModel(
        pageNumber: pageNumber ?? currentPage,
        pageSize: _pageSize,
        orderBy: 'CreatedAt:desc',
      );

      notificationPagination = await _notificationRepository.search(request);
      isLoading = false;
      notifyListeners();

      return true;
    } on SessionExpiredException {
      errorMessage = 'Session expired. Please login again.';
      isLoading = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isLoading = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      unreadCount = await _notificationRepository.getUnreadCount();
      notifyListeners();
    } catch (e) {
      // Silently fail for unread count
    }
  }

  Future<bool> markAsRead(String notificationUuid) async {
    try {
      await _notificationRepository.markAsRead(notificationUuid);

      final index = notificationPagination?.data.indexWhere(
        (n) => n.uuid == notificationUuid,
      );
      if (index != null && index >= 0) {
        final notification = notificationPagination!.data[index];
        notificationPagination!.data[index] = NotificationResponseApiModel(
          uuid: notification.uuid,
          actor: notification.actor,
          targetUser: notification.targetUser,
          notificationType: notification.notificationType,
          title: notification.title,
          message: notification.message,
          isRead: true,
          createdAt: notification.createdAt,
          readAt: DateTime.now(),
          relatedEntityUuid: notification.relatedEntityUuid,
          relatedEntityType: notification.relatedEntityType,
        );
        if (unreadCount > 0) unreadCount--;
        notifyListeners();
      }

      return true;
    } on SessionExpiredException {
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      onForbidden?.call();
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      await _notificationRepository.markAllAsRead();

      if (notificationPagination != null) {
        notificationPagination =
            PaginationResponseApiModel<NotificationResponseApiModel>(
              data: notificationPagination!.data.map((n) {
                return NotificationResponseApiModel(
                  uuid: n.uuid,
                  actor: n.actor,
                  targetUser: n.targetUser,
                  notificationType: n.notificationType,
                  title: n.title,
                  message: n.message,
                  isRead: true,
                  createdAt: n.createdAt,
                  readAt: n.readAt ?? DateTime.now(),
                  relatedEntityUuid: n.relatedEntityUuid,
                  relatedEntityType: n.relatedEntityType,
                );
              }).toList(),
              pageNumber: notificationPagination!.pageNumber,
              pageSize: notificationPagination!.pageSize,
              totalRecords: notificationPagination!.totalRecords,
              totalPages: notificationPagination!.totalPages,
              hasPreviousPage: notificationPagination!.hasPreviousPage,
              hasNextPage: notificationPagination!.hasNextPage,
              orderBy: notificationPagination!.orderBy,
            );
        unreadCount = 0;
        notifyListeners();
      }

      return true;
    } on SessionExpiredException {
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      onForbidden?.call();
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationUuid) async {
    try {
      await _notificationRepository.delete(notificationUuid);

      final notification = notificationPagination?.data.firstWhere(
        (n) => n.uuid == notificationUuid,
        orElse: () => throw Exception('Not found'),
      );

      if (notification != null && !notification.isRead && unreadCount > 0) {
        unreadCount--;
      }

      notificationPagination?.data.removeWhere(
        (n) => n.uuid == notificationUuid,
      );
      notifyListeners();

      return true;
    } on SessionExpiredException {
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      onForbidden?.call();
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    onSessionExpired = null;
    onForbidden = null;
    super.dispose();
  }
}

import 'package:joymodels_mobile/data/model/users/response_types/users_response_api_model.dart';

class NotificationResponseApiModel {
  final String uuid;
  final UsersResponseApiModel actor;
  final UsersResponseApiModel targetUser;
  final String notificationType;
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final String relatedEntityUuid;
  final String relatedEntityType;

  NotificationResponseApiModel({
    required this.uuid,
    required this.actor,
    required this.targetUser,
    required this.notificationType,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    required this.relatedEntityUuid,
    required this.relatedEntityType,
  });

  factory NotificationResponseApiModel.fromJson(Map<String, dynamic> json) {
    return NotificationResponseApiModel(
      uuid: json['uuid'],
      actor: UsersResponseApiModel.fromJson(json['actor']),
      targetUser: UsersResponseApiModel.fromJson(json['targetUser']),
      notificationType: json['notificationType'],
      title: json['title'],
      message: json['message'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      readAt: json['readAt'] != null ? DateTime.parse(json['readAt']) : null,
      relatedEntityUuid: json['relatedEntityUuid'],
      relatedEntityType: json['relatedEntityType'],
    );
  }
}

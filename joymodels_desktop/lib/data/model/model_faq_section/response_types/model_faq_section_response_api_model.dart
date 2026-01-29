import 'package:joymodels_desktop/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_desktop/data/model/users/response_types/users_response_api_model.dart';

class ModelFaqSectionResponseApiModel {
  final String uuid;
  final String messageText;
  final DateTime createdAt;
  final UsersResponseApiModel user;
  final ModelResponseApiModel model;
  final ModelFaqSectionParentDto? parentMessage;
  final List<ModelFaqSectionReplyDto>? replies;

  ModelFaqSectionResponseApiModel({
    required this.uuid,
    required this.messageText,
    required this.createdAt,
    required this.user,
    required this.model,
    this.parentMessage,
    this.replies,
  });

  factory ModelFaqSectionResponseApiModel.fromJson(Map<String, dynamic> json) {
    return ModelFaqSectionResponseApiModel(
      uuid: json['uuid'] as String,
      messageText: json['messageText'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      user: UsersResponseApiModel.fromJson(json['user']),
      model: ModelResponseApiModel.fromJson(json['model']),
      parentMessage: json['parentMessage'] != null
          ? ModelFaqSectionParentDto.fromJson(json['parentMessage'])
          : null,
      replies: json['replies'] != null
          ? (json['replies'] as List<dynamic>)
                .map((e) => ModelFaqSectionReplyDto.fromJson(e))
                .toList()
          : null,
    );
  }
}

class ModelFaqSectionParentDto {
  final String uuid;
  final String messageText;
  final DateTime createdAt;
  final UsersResponseApiModel user;

  ModelFaqSectionParentDto({
    required this.uuid,
    required this.messageText,
    required this.createdAt,
    required this.user,
  });

  factory ModelFaqSectionParentDto.fromJson(Map<String, dynamic> json) {
    return ModelFaqSectionParentDto(
      uuid: json['uuid'] as String,
      messageText: json['messageText'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      user: UsersResponseApiModel.fromJson(json['user']),
    );
  }
}

class ModelFaqSectionReplyDto {
  final String uuid;
  final String messageText;
  final DateTime createdAt;
  final UsersResponseApiModel user;

  ModelFaqSectionReplyDto({
    required this.uuid,
    required this.messageText,
    required this.createdAt,
    required this.user,
  });

  factory ModelFaqSectionReplyDto.fromJson(Map<String, dynamic> json) {
    return ModelFaqSectionReplyDto(
      uuid: json['uuid'] as String,
      messageText: json['messageText'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      user: UsersResponseApiModel.fromJson(json['user']),
    );
  }
}

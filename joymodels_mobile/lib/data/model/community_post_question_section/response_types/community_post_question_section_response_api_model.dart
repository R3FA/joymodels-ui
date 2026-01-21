import 'package:joymodels_mobile/data/model/community_post/response_types/community_post_response_api_model.dart';
import 'package:joymodels_mobile/data/model/users/response_types/users_response_api_model.dart';

class CommunityPostQuestionSectionResponseApiModel {
  final String uuid;
  final UsersResponseApiModel user;
  final CommunityPostResponseApiModel communityPost;
  final String messageText;
  final DateTime createdAt;
  final CommunityPostQuestionSectionParentApiModel? parentMessage;
  final List<CommunityPostQuestionSectionReplyApiModel>? replies;

  CommunityPostQuestionSectionResponseApiModel({
    required this.uuid,
    required this.user,
    required this.communityPost,
    required this.messageText,
    required this.createdAt,
    this.parentMessage,
    this.replies,
  });

  factory CommunityPostQuestionSectionResponseApiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CommunityPostQuestionSectionResponseApiModel(
      uuid: json['uuid'] as String,
      user: UsersResponseApiModel.fromJson(json['user']),
      communityPost: CommunityPostResponseApiModel.fromJson(
        json['communityPost'],
      ),
      messageText: json['messageText'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      parentMessage: json['parentMessage'] != null
          ? CommunityPostQuestionSectionParentApiModel.fromJson(
              json['parentMessage'],
            )
          : null,
      replies: json['replies'] != null
          ? (json['replies'] as List<dynamic>)
                .map(
                  (item) =>
                      CommunityPostQuestionSectionReplyApiModel.fromJson(item),
                )
                .toList()
          : null,
    );
  }
}

class CommunityPostQuestionSectionParentApiModel {
  final String uuid;
  final String messageText;
  final DateTime createdAt;
  final UsersResponseApiModel user;

  CommunityPostQuestionSectionParentApiModel({
    required this.uuid,
    required this.messageText,
    required this.createdAt,
    required this.user,
  });

  factory CommunityPostQuestionSectionParentApiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CommunityPostQuestionSectionParentApiModel(
      uuid: json['uuid'] as String,
      messageText: json['messageText'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      user: UsersResponseApiModel.fromJson(json['user']),
    );
  }
}

class CommunityPostQuestionSectionReplyApiModel {
  final String uuid;
  final String messageText;
  final DateTime createdAt;
  final UsersResponseApiModel user;

  CommunityPostQuestionSectionReplyApiModel({
    required this.uuid,
    required this.messageText,
    required this.createdAt,
    required this.user,
  });

  factory CommunityPostQuestionSectionReplyApiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CommunityPostQuestionSectionReplyApiModel(
      uuid: json['uuid'] as String,
      messageText: json['messageText'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      user: UsersResponseApiModel.fromJson(json['user']),
    );
  }
}

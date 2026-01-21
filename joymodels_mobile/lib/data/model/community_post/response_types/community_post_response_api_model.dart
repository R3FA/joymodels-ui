import 'package:joymodels_mobile/data/model/community_post/response_types/community_post_picture_response_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post_type/response_types/community_post_type_response_api_model.dart';
import 'package:joymodels_mobile/data/model/users/response_types/users_response_api_model.dart';

class CommunityPostResponseApiModel {
  final String uuid;
  final UsersResponseApiModel user;
  final String title;
  final String description;
  final String? youtubeVideoLink;
  final int communityPostLikes;
  final int communityPostDislikes;
  final int communityPostCommentCount;
  final CommunityPostTypeResponseApiModel communityPostType;
  final List<CommunityPostPictureResponseApiModel> pictureLocations;

  CommunityPostResponseApiModel({
    required this.uuid,
    required this.user,
    required this.title,
    required this.description,
    this.youtubeVideoLink,
    required this.communityPostLikes,
    required this.communityPostDislikes,
    required this.communityPostCommentCount,
    required this.communityPostType,
    required this.pictureLocations,
  });

  factory CommunityPostResponseApiModel.fromJson(Map<String, dynamic> json) {
    return CommunityPostResponseApiModel(
      uuid: json['uuid'] as String,
      user: UsersResponseApiModel.fromJson(json['user']),
      title: json['title'] as String,
      description: json['description'] as String,
      youtubeVideoLink: json['youtubeVideoLink'] as String?,
      communityPostLikes: json['communityPostLikes'] as int,
      communityPostDislikes: json['communityPostDislikes'] as int,
      communityPostCommentCount: json['communityPostCommentCount'] as int,
      communityPostType: CommunityPostTypeResponseApiModel.fromJson(
        json['communityPostType'],
      ),
      pictureLocations: (json['pictureLocations'] as List<dynamic>)
          .map((item) => CommunityPostPictureResponseApiModel.fromJson(item))
          .toList(),
    );
  }
}

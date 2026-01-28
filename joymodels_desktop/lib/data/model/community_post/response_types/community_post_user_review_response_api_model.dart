import 'package:joymodels_desktop/data/model/community_post_review_type/response_types/community_post_review_type_response_api_model.dart';
import 'package:joymodels_desktop/data/model/users/response_types/users_response_api_model.dart';

class CommunityPostUserReviewResponseApiModel {
  final String uuid;
  final UsersResponseApiModel user;
  final CommunityPostReviewTypeResponseApiModel reviewType;

  CommunityPostUserReviewResponseApiModel({
    required this.uuid,
    required this.user,
    required this.reviewType,
  });

  factory CommunityPostUserReviewResponseApiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CommunityPostUserReviewResponseApiModel(
      uuid: json['uuid'] as String,
      user: UsersResponseApiModel.fromJson(json['user']),
      reviewType: CommunityPostReviewTypeResponseApiModel.fromJson(
        json['reviewType'],
      ),
    );
  }
}

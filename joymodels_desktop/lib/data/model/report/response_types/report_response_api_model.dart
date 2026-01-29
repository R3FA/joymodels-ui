import 'package:joymodels_desktop/data/model/community_post/response_types/community_post_response_api_model.dart';
import 'package:joymodels_desktop/data/model/community_post_question_section/response_types/community_post_question_section_response_api_model.dart';
import 'package:joymodels_desktop/data/model/model_faq_section/response_types/model_faq_section_response_api_model.dart';
import 'package:joymodels_desktop/data/model/model_reviews/response_types/model_review_response_api_model.dart';
import 'package:joymodels_desktop/data/model/users/response_types/users_response_api_model.dart';

class ReportResponseApiModel {
  final String uuid;
  final UsersResponseApiModel reporter;
  final String reportedEntityType;
  final String reportedEntityUuid;
  final String reason;
  final String? description;
  final String status;
  final UsersResponseApiModel? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  final UsersResponseApiModel? reportedUser;
  final CommunityPostResponseApiModel? reportedCommunityPost;
  final CommunityPostQuestionSectionResponseApiModel?
  reportedCommunityPostComment;
  final ModelReviewResponseApiModel? reportedModelReview;
  final ModelFaqSectionResponseApiModel? reportedModelFaqQuestion;

  ReportResponseApiModel({
    required this.uuid,
    required this.reporter,
    required this.reportedEntityType,
    required this.reportedEntityUuid,
    required this.reason,
    this.description,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
    this.reportedUser,
    this.reportedCommunityPost,
    this.reportedCommunityPostComment,
    this.reportedModelReview,
    this.reportedModelFaqQuestion,
  });

  factory ReportResponseApiModel.fromJson(Map<String, dynamic> json) {
    return ReportResponseApiModel(
      uuid: json['uuid'],
      reporter: UsersResponseApiModel.fromJson(json['reporter']),
      reportedEntityType: json['reportedEntityType'],
      reportedEntityUuid: json['reportedEntityUuid'],
      reason: json['reason'],
      description: json['description'],
      status: json['status'],
      reviewedBy: json['reviewedBy'] != null
          ? UsersResponseApiModel.fromJson(json['reviewedBy'])
          : null,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      reportedUser: json['reportedUser'] != null
          ? UsersResponseApiModel.fromJson(json['reportedUser'])
          : null,
      reportedCommunityPost: json['reportedCommunityPost'] != null
          ? CommunityPostResponseApiModel.fromJson(
              json['reportedCommunityPost'],
            )
          : null,
      reportedCommunityPostComment: json['reportedCommunityPostComment'] != null
          ? CommunityPostQuestionSectionResponseApiModel.fromJson(
              json['reportedCommunityPostComment'],
            )
          : null,
      reportedModelReview: json['reportedModelReview'] != null
          ? ModelReviewResponseApiModel.fromJson(json['reportedModelReview'])
          : null,
      reportedModelFaqQuestion: json['reportedModelFaqQuestion'] != null
          ? ModelFaqSectionResponseApiModel.fromJson(
              json['reportedModelFaqQuestion'],
            )
          : null,
    );
  }

  String? getPreviewText() {
    if (reportedUser != null) {
      return reportedUser!.nickName;
    } else if (reportedCommunityPost != null) {
      return reportedCommunityPost!.title;
    } else if (reportedCommunityPostComment != null) {
      return reportedCommunityPostComment!.messageText;
    } else if (reportedModelReview != null) {
      return reportedModelReview!.modelReviewText;
    } else if (reportedModelFaqQuestion != null) {
      return reportedModelFaqQuestion!.messageText;
    }
    return null;
  }
}

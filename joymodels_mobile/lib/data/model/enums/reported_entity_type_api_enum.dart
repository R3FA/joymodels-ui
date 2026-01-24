enum ReportedEntityTypeApiEnum {
  user,
  communityPost,
  communityPostComment,
  modelReview,
  modelFaqQuestion;

  String toApiString() {
    switch (this) {
      case ReportedEntityTypeApiEnum.user:
        return 'User';
      case ReportedEntityTypeApiEnum.communityPost:
        return 'CommunityPost';
      case ReportedEntityTypeApiEnum.communityPostComment:
        return 'CommunityPostComment';
      case ReportedEntityTypeApiEnum.modelReview:
        return 'ModelReview';
      case ReportedEntityTypeApiEnum.modelFaqQuestion:
        return 'ModelFaqQuestion';
    }
  }

  static ReportedEntityTypeApiEnum fromApiString(String value) {
    switch (value) {
      case 'User':
        return ReportedEntityTypeApiEnum.user;
      case 'CommunityPost':
        return ReportedEntityTypeApiEnum.communityPost;
      case 'CommunityPostComment':
        return ReportedEntityTypeApiEnum.communityPostComment;
      case 'ModelReview':
        return ReportedEntityTypeApiEnum.modelReview;
      case 'ModelFaqQuestion':
        return ReportedEntityTypeApiEnum.modelFaqQuestion;
      default:
        return ReportedEntityTypeApiEnum.user;
    }
  }
}

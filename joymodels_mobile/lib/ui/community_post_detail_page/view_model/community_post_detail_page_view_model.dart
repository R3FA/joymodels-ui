import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/network_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_user_review_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_user_review_delete_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post/response_types/community_post_response_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post_question_section/request_types/community_post_question_section_create_answer_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post_question_section/request_types/community_post_question_section_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post_question_section/request_types/community_post_question_section_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post_question_section/response_types/community_post_question_section_response_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post_review_type/request_types/community_post_review_type_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post_review_type/response_types/community_post_review_type_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/community_post_question_section_repository.dart';
import 'package:joymodels_mobile/data/repositories/community_post_repository.dart';
import 'package:joymodels_mobile/data/repositories/community_post_review_type_repository.dart';
import 'package:joymodels_mobile/ui/core/mixins/pagination_mixin.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';

class CommunityPostDetailPageViewModel extends ChangeNotifier
    with PaginationMixin<CommunityPostQuestionSectionResponseApiModel> {
  final communityPostRepository = sl<CommunityPostRepository>();
  final communityPostReviewTypeRepository =
      sl<CommunityPostReviewTypeRepository>();
  final communityPostQuestionSectionRepository =
      sl<CommunityPostQuestionSectionRepository>();

  CommunityPostResponseApiModel? post;
  bool isLoading = false;
  String? errorMessage;

  List<CommunityPostReviewTypeResponseApiModel> reviewTypes = [];
  CommunityPostReviewTypeResponseApiModel? likeReviewType;
  CommunityPostReviewTypeResponseApiModel? dislikeReviewType;

  bool isLiked = false;
  bool isDisliked = false;

  int currentImageIndex = 0;
  final PageController galleryController = PageController();

  PaginationResponseApiModel<CommunityPostQuestionSectionResponseApiModel>?
  questionsPagination;
  bool isLoadingQuestions = false;

  List<CommunityPostQuestionSectionResponseApiModel> get questions =>
      questionsPagination?.data ?? [];

  @override
  PaginationResponseApiModel<CommunityPostQuestionSectionResponseApiModel>?
  get paginationData => questionsPagination;

  @override
  bool get isLoadingPage => isLoadingQuestions;

  @override
  Future<void> loadPage(int pageNumber) async {
    await loadQuestions(pageNumber: pageNumber);
  }

  final TextEditingController questionController = TextEditingController();
  final TextEditingController replyController = TextEditingController();
  bool isSubmittingQuestion = false;
  bool isSubmittingReply = false;
  String? replyingToQuestionUuid;

  final Map<String, int> _visibleRepliesCount = {};
  final Set<String> _expandedQuestions = {};
  static const int _repliesPerPage = 5;

  bool isRepliesExpanded(String questionUuid) {
    return _expandedQuestions.contains(questionUuid);
  }

  int getVisibleRepliesCount(String questionUuid) {
    return _visibleRepliesCount[questionUuid] ?? _repliesPerPage;
  }

  void toggleReplies(String questionUuid) {
    if (_expandedQuestions.contains(questionUuid)) {
      _expandedQuestions.remove(questionUuid);
      _visibleRepliesCount.remove(questionUuid);
    } else {
      _expandedQuestions.add(questionUuid);
      _visibleRepliesCount[questionUuid] = _repliesPerPage;
    }
    notifyListeners();
  }

  void loadMoreReplies(String questionUuid) {
    final current = _visibleRepliesCount[questionUuid] ?? _repliesPerPage;
    _visibleRepliesCount[questionUuid] = current + _repliesPerPage;
    notifyListeners();
  }

  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;
  VoidCallback? onPostDeleted;

  String? currentUserUuid;

  bool isOwner(String userUuid) {
    return currentUserUuid != null && currentUserUuid == userUuid;
  }

  bool get isPostOwner {
    if (post == null || currentUserUuid == null) return false;
    return post!.user.uuid == currentUserUuid;
  }

  Future<void> init(CommunityPostResponseApiModel loadedPost) async {
    isLoading = true;
    notifyListeners();

    try {
      post = loadedPost;
      currentUserUuid = await TokenStorage.getCurrentUserUuid();
      await Future.wait([
        _loadReviewTypes(),
        _loadUserReviewStatus(),
        loadQuestions(),
      ]);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadReviewTypes() async {
    final response = await communityPostReviewTypeRepository.search(
      CommunityPostReviewTypeSearchRequestApiModel(pageNumber: 1, pageSize: 10),
    );
    reviewTypes = response.data;

    for (final type in reviewTypes) {
      if (type.reviewName.toLowerCase() == 'positive') {
        likeReviewType = type;
      } else if (type.reviewName.toLowerCase() == 'negative') {
        dislikeReviewType = type;
      }
    }
  }

  Future<void> _loadUserReviewStatus() async {
    if (post == null) return;

    try {
      final results = await Future.wait([
        communityPostRepository.isLiked(post!.uuid),
        communityPostRepository.isDisliked(post!.uuid),
      ]);

      isLiked = results[0];
      isDisliked = results[1];
    } catch (_) {}
  }

  Future<void> onLikePressed() async {
    if (likeReviewType == null || post == null) return;

    try {
      if (isLiked) {
        await communityPostRepository.deleteUserReview(
          CommunityPostUserReviewDeleteRequestApiModel(
            communityPostUuid: post!.uuid,
            reviewTypeUuid: likeReviewType!.uuid,
          ),
        );
        isLiked = false;
        _updateLikeCount(-1, 0);
      } else {
        if (isDisliked && dislikeReviewType != null) {
          await communityPostRepository.deleteUserReview(
            CommunityPostUserReviewDeleteRequestApiModel(
              communityPostUuid: post!.uuid,
              reviewTypeUuid: dislikeReviewType!.uuid,
            ),
          );
          isDisliked = false;
          _updateLikeCount(0, -1);
        }
        await communityPostRepository.createUserReview(
          CommunityPostUserReviewCreateRequestApiModel(
            communityPostUuid: post!.uuid,
            reviewTypeUuid: likeReviewType!.uuid,
          ),
        );
        isLiked = true;
        _updateLikeCount(1, 0);
      }
      notifyListeners();
    } on SessionExpiredException {
      onSessionExpired?.call();
    } on ForbiddenException {
      onForbidden?.call();
    } on NetworkException {
      errorMessage = NetworkException().toString();
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> onDislikePressed() async {
    if (dislikeReviewType == null || post == null) return;

    try {
      if (isDisliked) {
        await communityPostRepository.deleteUserReview(
          CommunityPostUserReviewDeleteRequestApiModel(
            communityPostUuid: post!.uuid,
            reviewTypeUuid: dislikeReviewType!.uuid,
          ),
        );
        isDisliked = false;
        _updateLikeCount(0, -1);
      } else {
        if (isLiked && likeReviewType != null) {
          await communityPostRepository.deleteUserReview(
            CommunityPostUserReviewDeleteRequestApiModel(
              communityPostUuid: post!.uuid,
              reviewTypeUuid: likeReviewType!.uuid,
            ),
          );
          isLiked = false;
          _updateLikeCount(-1, 0);
        }
        await communityPostRepository.createUserReview(
          CommunityPostUserReviewCreateRequestApiModel(
            communityPostUuid: post!.uuid,
            reviewTypeUuid: dislikeReviewType!.uuid,
          ),
        );
        isDisliked = true;
        _updateLikeCount(0, 1);
      }
      notifyListeners();
    } on SessionExpiredException {
      onSessionExpired?.call();
    } on ForbiddenException {
      onForbidden?.call();
    } on NetworkException {
      errorMessage = NetworkException().toString();
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _updateLikeCount(int likeDelta, int dislikeDelta) {
    if (post == null) return;

    post = CommunityPostResponseApiModel(
      uuid: post!.uuid,
      user: post!.user,
      title: post!.title,
      description: post!.description,
      youtubeVideoLink: post!.youtubeVideoLink,
      communityPostLikes: post!.communityPostLikes + likeDelta,
      communityPostDislikes: post!.communityPostDislikes + dislikeDelta,
      communityPostCommentCount: post!.communityPostCommentCount,
      communityPostType: post!.communityPostType,
      pictureLocations: post!.pictureLocations,
    );
  }

  void onGalleryPageChanged(int index) {
    currentImageIndex = index;
    notifyListeners();
  }

  void nextImage() {
    if (post == null) return;
    if (currentImageIndex < post!.pictureLocations.length - 1) {
      galleryController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousImage() {
    if (currentImageIndex > 0) {
      galleryController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool get hasImages => post?.pictureLocations.isNotEmpty ?? false;

  bool get hasYoutubeLink =>
      post?.youtubeVideoLink != null && post!.youtubeVideoLink!.isNotEmpty;

  String? extractYoutubeVideoId(String url) {
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:watch\?v=|embed\/|v\/)|youtu\.be\/)([a-zA-Z0-9_-]{11})',
    );
    final match = regExp.firstMatch(url);
    return match?.group(1);
  }

  Future<void> loadQuestions({int? pageNumber}) async {
    if (post == null) return;

    isLoadingQuestions = true;
    notifyListeners();

    try {
      final response = await communityPostQuestionSectionRepository.search(
        CommunityPostQuestionSectionSearchRequestApiModel(
          communityPostUuid: post!.uuid,
          pageNumber: pageNumber ?? currentPage,
          pageSize: 10,
        ),
      );

      final parentQuestions = response.data
          .where((q) => q.parentMessage == null)
          .toList();

      questionsPagination =
          PaginationResponseApiModel<
            CommunityPostQuestionSectionResponseApiModel
          >(
            pageNumber: response.pageNumber,
            pageSize: response.pageSize,
            totalRecords: response.totalRecords,
            totalPages: response.totalPages,
            hasPreviousPage: response.hasPreviousPage,
            hasNextPage: response.hasNextPage,
            orderBy: response.orderBy,
            data: parentQuestions,
          );

      isLoadingQuestions = false;
      notifyListeners();
    } on SessionExpiredException {
      isLoadingQuestions = false;
      notifyListeners();
      onSessionExpired?.call();
    } on ForbiddenException {
      isLoadingQuestions = false;
      notifyListeners();
      onForbidden?.call();
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isLoadingQuestions = false;
      notifyListeners();
    } catch (e) {
      isLoadingQuestions = false;
      errorMessage = 'Failed to load questions: $e';
      notifyListeners();
    }
  }

  String? validateQuestionText(String? text) {
    return RegexValidationViewModel.validateText(text);
  }

  Future<void> submitQuestion() async {
    if (post == null) return;

    final validationError = validateQuestionText(questionController.text);
    if (validationError != null) {
      errorMessage = validationError;
      notifyListeners();
      return;
    }

    isSubmittingQuestion = true;
    notifyListeners();

    try {
      await communityPostQuestionSectionRepository.create(
        CommunityPostQuestionSectionCreateRequestApiModel(
          communityPostUuid: post!.uuid,
          messageText: questionController.text.trim(),
        ),
      );

      questionController.clear();
      isSubmittingQuestion = false;

      await _refreshPost();
      await loadQuestions(pageNumber: 1);
    } on SessionExpiredException {
      isSubmittingQuestion = false;
      notifyListeners();
      onSessionExpired?.call();
    } on ForbiddenException {
      isSubmittingQuestion = false;
      notifyListeners();
      onForbidden?.call();
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isSubmittingQuestion = false;
      notifyListeners();
    } catch (e) {
      isSubmittingQuestion = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  void startReply(String questionUuid) {
    replyingToQuestionUuid = questionUuid;
    replyController.clear();
    notifyListeners();
  }

  void cancelReply() {
    replyingToQuestionUuid = null;
    replyController.clear();
    notifyListeners();
  }

  Future<void> submitReply(String parentMessageUuid) async {
    if (post == null) return;

    final validationError = validateQuestionText(replyController.text);
    if (validationError != null) {
      errorMessage = validationError;
      notifyListeners();
      return;
    }

    isSubmittingReply = true;
    notifyListeners();

    try {
      await communityPostQuestionSectionRepository.createAnswer(
        CommunityPostQuestionSectionCreateAnswerRequestApiModel(
          communityPostUuid: post!.uuid,
          parentMessageUuid: parentMessageUuid,
          messageText: replyController.text.trim(),
        ),
      );

      replyingToQuestionUuid = null;
      replyController.clear();
      isSubmittingReply = false;

      await _refreshPost();
      await reloadCurrentPage();
    } on SessionExpiredException {
      isSubmittingReply = false;
      notifyListeners();
      onSessionExpired?.call();
    } on ForbiddenException {
      isSubmittingReply = false;
      notifyListeners();
      onForbidden?.call();
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isSubmittingReply = false;
      notifyListeners();
    } catch (e) {
      isSubmittingReply = false;
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteQuestion(String uuid) async {
    try {
      await communityPostQuestionSectionRepository.delete(uuid);
      await _refreshPost();
      await reloadCurrentPage();
    } on SessionExpiredException {
      onSessionExpired?.call();
    } on ForbiddenException {
      onForbidden?.call();
    } on NetworkException {
      errorMessage = NetworkException().toString();
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> deletePost() async {
    if (post == null) return;

    try {
      await communityPostRepository.delete(post!.uuid);
      onPostDeleted?.call();
    } on SessionExpiredException {
      onSessionExpired?.call();
    } on ForbiddenException {
      onForbidden?.call();
    } on NetworkException {
      errorMessage = NetworkException().toString();
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> _refreshPost() async {
    if (post == null) return;

    try {
      post = await communityPostRepository.getByUuid(post!.uuid);
      notifyListeners();
    } catch (_) {}
  }

  void updatePost(CommunityPostResponseApiModel updatedPost) {
    post = updatedPost;
    currentImageIndex = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    galleryController.dispose();
    questionController.dispose();
    replyController.dispose();
    onSessionExpired = null;
    onForbidden = null;
    super.dispose();
  }
}

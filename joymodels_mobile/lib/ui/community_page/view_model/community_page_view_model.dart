import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_user_review_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_user_review_delete_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post/response_types/community_post_response_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post_review_type/request_types/community_post_review_type_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post_review_type/response_types/community_post_review_type_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/community_post_repository.dart';
import 'package:joymodels_mobile/data/repositories/community_post_review_type_repository.dart';
import 'package:joymodels_mobile/ui/community_post_create_page/view_model/community_post_create_page_view_model.dart';
import 'package:joymodels_mobile/ui/community_post_create_page/widgets/community_post_create_page_screen.dart';
import 'package:joymodels_mobile/ui/community_post_detail_page/view_model/community_post_detail_page_view_model.dart';
import 'package:joymodels_mobile/ui/community_post_detail_page/widgets/community_post_detail_page_screen.dart';
import 'package:joymodels_mobile/ui/core/mixins/pagination_mixin.dart';
import 'package:provider/provider.dart';

class CommunityPageViewModel extends ChangeNotifier
    with PaginationMixin<CommunityPostResponseApiModel> {
  final communityPostRepository = sl<CommunityPostRepository>();
  final communityPostReviewTypeRepository =
      sl<CommunityPostReviewTypeRepository>();

  final searchController = TextEditingController();

  bool isLoading = false;
  bool isSearching = false;
  bool arePostsLoading = false;

  String? errorMessage;

  PaginationResponseApiModel<CommunityPostResponseApiModel>? posts;

  List<CommunityPostReviewTypeResponseApiModel> reviewTypes = [];
  CommunityPostReviewTypeResponseApiModel? likeReviewType;
  CommunityPostReviewTypeResponseApiModel? dislikeReviewType;

  // Track which posts user has liked/disliked (postUuid -> reviewType)
  final Map<String, String> _userReviews = {};

  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;

  @override
  PaginationResponseApiModel<CommunityPostResponseApiModel>?
  get paginationData => posts;

  @override
  bool get isLoadingPage => arePostsLoading;

  @override
  Future<void> loadPage(int pageNumber) async {
    await searchPosts(
      CommunityPostSearchRequestApiModel(
        title: searchController.text.isNotEmpty ? searchController.text : null,
        pageNumber: pageNumber,
        pageSize: 5,
      ),
    );
  }

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        _loadReviewTypes(),
        searchPosts(
          CommunityPostSearchRequestApiModel(pageNumber: 1, pageSize: 5),
        ),
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

  Future<void> _loadUserReviewsForPosts() async {
    if (posts == null || posts!.data.isEmpty) return;

    for (final post in posts!.data) {
      try {
        final results = await Future.wait([
          communityPostRepository.isLiked(post.uuid),
          communityPostRepository.isDisliked(post.uuid),
        ]);

        final isLiked = results[0];
        final isDisliked = results[1];

        if (isLiked) {
          _userReviews[post.uuid] = 'like';
        } else if (isDisliked) {
          _userReviews[post.uuid] = 'dislike';
        } else {
          _userReviews.remove(post.uuid);
        }
      } catch (e) {
        // Ignore errors for individual posts
      }
    }
  }

  Future<bool> searchPosts(CommunityPostSearchRequestApiModel request) async {
    errorMessage = null;
    arePostsLoading = true;
    notifyListeners();

    try {
      posts = await communityPostRepository.search(request);
      await _loadUserReviewsForPosts();
      arePostsLoading = false;
      notifyListeners();
      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      arePostsLoading = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      arePostsLoading = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      arePostsLoading = false;
      notifyListeners();
      return false;
    }
  }

  void onSearchPressed() {
    isSearching = true;
    notifyListeners();
  }

  void onSearchCancelled() {
    isSearching = false;
    searchController.clear();
    notifyListeners();
  }

  void onSearchSubmitted(String query) {
    searchPosts(
      CommunityPostSearchRequestApiModel(
        title: query.isNotEmpty ? query : null,
        pageNumber: 1,
        pageSize: 5,
      ),
    );
  }

  Future<void> onCreatePostPressed(BuildContext context) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => CommunityPostCreatePageViewModel(),
          child: const CommunityPostCreatePageScreen(),
        ),
      ),
    );

    if (result == true) {
      await onRefresh();
    }
  }

  void onPostTap(BuildContext context, CommunityPostResponseApiModel post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => CommunityPostDetailPageViewModel()..init(post),
          child: const CommunityPostDetailPageScreen(),
        ),
      ),
    );
  }

  bool isPostLiked(String postUuid) {
    return _userReviews[postUuid] == 'like';
  }

  bool isPostDisliked(String postUuid) {
    return _userReviews[postUuid] == 'dislike';
  }

  void setPostReviewStatus(String postUuid, String? status) {
    if (status == null) {
      _userReviews.remove(postUuid);
    } else {
      _userReviews[postUuid] = status;
    }
    notifyListeners();
  }

  Future<void> onLikePressed(CommunityPostResponseApiModel post) async {
    if (likeReviewType == null) return;

    try {
      if (isPostLiked(post.uuid)) {
        // Already liked, remove like
        await communityPostRepository.deleteUserReview(
          CommunityPostUserReviewDeleteRequestApiModel(
            communityPostUuid: post.uuid,
            reviewTypeUuid: likeReviewType!.uuid,
          ),
        );
        setPostReviewStatus(post.uuid, null);
        _updatePostLikeCount(post.uuid, -1, 0);
      } else {
        // If disliked, remove dislike first
        if (isPostDisliked(post.uuid) && dislikeReviewType != null) {
          await communityPostRepository.deleteUserReview(
            CommunityPostUserReviewDeleteRequestApiModel(
              communityPostUuid: post.uuid,
              reviewTypeUuid: dislikeReviewType!.uuid,
            ),
          );
          _updatePostLikeCount(post.uuid, 0, -1);
        }
        // Add like
        await communityPostRepository.createUserReview(
          CommunityPostUserReviewCreateRequestApiModel(
            communityPostUuid: post.uuid,
            reviewTypeUuid: likeReviewType!.uuid,
          ),
        );
        setPostReviewStatus(post.uuid, 'like');
        _updatePostLikeCount(post.uuid, 1, 0);
      }
    } on SessionExpiredException {
      onSessionExpired?.call();
    } on ForbiddenException {
      onForbidden?.call();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> onDislikePressed(CommunityPostResponseApiModel post) async {
    if (dislikeReviewType == null) return;

    try {
      if (isPostDisliked(post.uuid)) {
        // Already disliked, remove dislike
        await communityPostRepository.deleteUserReview(
          CommunityPostUserReviewDeleteRequestApiModel(
            communityPostUuid: post.uuid,
            reviewTypeUuid: dislikeReviewType!.uuid,
          ),
        );
        setPostReviewStatus(post.uuid, null);
        _updatePostLikeCount(post.uuid, 0, -1);
      } else {
        // If liked, remove like first
        if (isPostLiked(post.uuid) && likeReviewType != null) {
          await communityPostRepository.deleteUserReview(
            CommunityPostUserReviewDeleteRequestApiModel(
              communityPostUuid: post.uuid,
              reviewTypeUuid: likeReviewType!.uuid,
            ),
          );
          _updatePostLikeCount(post.uuid, -1, 0);
        }
        // Add dislike
        await communityPostRepository.createUserReview(
          CommunityPostUserReviewCreateRequestApiModel(
            communityPostUuid: post.uuid,
            reviewTypeUuid: dislikeReviewType!.uuid,
          ),
        );
        setPostReviewStatus(post.uuid, 'dislike');
        _updatePostLikeCount(post.uuid, 0, 1);
      }
    } on SessionExpiredException {
      onSessionExpired?.call();
    } on ForbiddenException {
      onForbidden?.call();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _updatePostLikeCount(String postUuid, int likeDelta, int dislikeDelta) {
    if (posts == null) return;

    final postIndex = posts!.data.indexWhere((p) => p.uuid == postUuid);
    if (postIndex == -1) return;

    final post = posts!.data[postIndex];
    posts!.data[postIndex] = CommunityPostResponseApiModel(
      uuid: post.uuid,
      user: post.user,
      title: post.title,
      description: post.description,
      youtubeVideoLink: post.youtubeVideoLink,
      communityPostLikes: post.communityPostLikes + likeDelta,
      communityPostDislikes: post.communityPostDislikes + dislikeDelta,
      communityPostCommentCount: post.communityPostCommentCount,
      communityPostType: post.communityPostType,
      pictureLocations: post.pictureLocations,
    );
    notifyListeners();
  }

  Future<void> onRefresh() async {
    await searchPosts(
      CommunityPostSearchRequestApiModel(
        title: searchController.text.isNotEmpty ? searchController.text : null,
        pageNumber: 1,
        pageSize: 5,
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    onSessionExpired = null;
    onForbidden = null;
    super.dispose();
  }
}

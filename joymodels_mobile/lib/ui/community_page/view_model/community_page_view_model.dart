import 'dart:async';

import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/network_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/api_exception.dart';
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
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';
import 'package:provider/provider.dart';

class CommunityPageViewModel extends ChangeNotifier
    with PaginationMixin<CommunityPostResponseApiModel> {
  final communityPostRepository = sl<CommunityPostRepository>();
  final communityPostReviewTypeRepository =
      sl<CommunityPostReviewTypeRepository>();

  final searchController = TextEditingController();

  Timer? _searchDebounce;

  bool isLoading = false;
  bool isSearching = false;
  bool arePostsLoading = false;

  String? errorMessage;
  String? searchError;

  String? currentUserUuid;
  int selectedTabIndex = 0;

  PaginationResponseApiModel<CommunityPostResponseApiModel>? posts;

  List<CommunityPostReviewTypeResponseApiModel> reviewTypes = [];
  CommunityPostReviewTypeResponseApiModel? likeReviewType;
  CommunityPostReviewTypeResponseApiModel? dislikeReviewType;

  final Map<String, String> _userReviews = {};

  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;

  @override
  PaginationResponseApiModel<CommunityPostResponseApiModel>?
  get paginationData => posts;

  @override
  bool get isLoadingPage => arePostsLoading;

  String? get _currentUserUuidForSearch =>
      selectedTabIndex == 1 ? currentUserUuid : null;

  @override
  Future<void> loadPage(int pageNumber) async {
    await searchPosts(
      CommunityPostSearchRequestApiModel(
        title: searchController.text.isNotEmpty ? searchController.text : null,
        userUuid: _currentUserUuidForSearch,
        pageNumber: pageNumber,
        pageSize: 5,
        orderBy: 'CreatedAt:desc',
      ),
    );
  }

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    try {
      currentUserUuid = await TokenStorage.getCurrentUserUuid();
      await Future.wait([
        _loadReviewTypes(),
        searchPosts(
          CommunityPostSearchRequestApiModel(
            pageNumber: 1,
            pageSize: 5,
            orderBy: 'CreatedAt:desc',
          ),
        ),
      ]);
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      onSessionExpired?.call();
    } on ForbiddenException {
      onForbidden?.call();
    } on NetworkException {
      errorMessage = NetworkException().toString();
    } on ApiException catch (e) {
      errorMessage = e.message;
    }
    isLoading = false;
    notifyListeners();
  }

  void onTabChanged(int index) {
    if (selectedTabIndex == index) return;
    selectedTabIndex = index;
    searchController.clear();
    searchError = null;
    notifyListeners();
    onRefresh();
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
      } on SessionExpiredException {
        errorMessage = SessionExpiredException().toString();
        onSessionExpired?.call();
        return;
      } on ForbiddenException {
        onForbidden?.call();
        return;
      } on NetworkException {
        errorMessage = NetworkException().toString();
        return;
      } on ApiException catch (e) {
        errorMessage = e.message;
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
    } on NetworkException {
      errorMessage = NetworkException().toString();
      arePostsLoading = false;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      errorMessage = e.message;
      arePostsLoading = false;
      notifyListeners();
      return false;
    }
  }

  void onSearchPressed() {
    isSearching = true;
    searchController.addListener(_onSearchChanged);
    notifyListeners();
  }

  void onSearchCancelled() {
    _searchDebounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    isSearching = false;
    searchError = null;
    searchController.clear();
    onRefresh();
    notifyListeners();
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();

    final query = searchController.text;

    if (query.isEmpty) {
      searchError = null;
      notifyListeners();
      onRefresh();
      return;
    }

    final validationError = RegexValidationViewModel.validateText(query);
    if (validationError != null) {
      searchError = validationError;
      notifyListeners();
      return;
    }

    searchError = null;
    notifyListeners();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      searchPosts(
        CommunityPostSearchRequestApiModel(
          title: query,
          userUuid: _currentUserUuidForSearch,
          pageNumber: 1,
          pageSize: 5,
          orderBy: 'CreatedAt:desc',
        ),
      );
    });
  }

  void onSearchSubmitted(String query) {
    _searchDebounce?.cancel();

    if (query.isNotEmpty) {
      final validationError = RegexValidationViewModel.validateText(query);
      if (validationError != null) {
        searchError = validationError;
        notifyListeners();
        return;
      }
    }

    searchError = null;
    searchPosts(
      CommunityPostSearchRequestApiModel(
        title: query.isNotEmpty ? query : null,
        userUuid: _currentUserUuidForSearch,
        pageNumber: 1,
        pageSize: 5,
        orderBy: 'CreatedAt:desc',
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

  Future<void> onPostTap(
    BuildContext context,
    CommunityPostResponseApiModel post,
  ) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => CommunityPostDetailPageViewModel()..init(post),
          child: const CommunityPostDetailPageScreen(),
        ),
      ),
    );

    if (result == true) {
      await reloadCurrentPage();
    }
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
        await communityPostRepository.deleteUserReview(
          CommunityPostUserReviewDeleteRequestApiModel(
            communityPostUuid: post.uuid,
            reviewTypeUuid: likeReviewType!.uuid,
          ),
        );
        setPostReviewStatus(post.uuid, null);
        _updatePostLikeCount(post.uuid, -1, 0);
      } else {
        if (isPostDisliked(post.uuid) && dislikeReviewType != null) {
          await communityPostRepository.deleteUserReview(
            CommunityPostUserReviewDeleteRequestApiModel(
              communityPostUuid: post.uuid,
              reviewTypeUuid: dislikeReviewType!.uuid,
            ),
          );
          _updatePostLikeCount(post.uuid, 0, -1);
        }
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
    } on NetworkException {
      errorMessage = NetworkException().toString();
      notifyListeners();
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> onDislikePressed(CommunityPostResponseApiModel post) async {
    if (dislikeReviewType == null) return;

    try {
      if (isPostDisliked(post.uuid)) {
        await communityPostRepository.deleteUserReview(
          CommunityPostUserReviewDeleteRequestApiModel(
            communityPostUuid: post.uuid,
            reviewTypeUuid: dislikeReviewType!.uuid,
          ),
        );
        setPostReviewStatus(post.uuid, null);
        _updatePostLikeCount(post.uuid, 0, -1);
      } else {
        if (isPostLiked(post.uuid) && likeReviewType != null) {
          await communityPostRepository.deleteUserReview(
            CommunityPostUserReviewDeleteRequestApiModel(
              communityPostUuid: post.uuid,
              reviewTypeUuid: likeReviewType!.uuid,
            ),
          );
          _updatePostLikeCount(post.uuid, -1, 0);
        }
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
    } on NetworkException {
      errorMessage = NetworkException().toString();
      notifyListeners();
    } on ApiException catch (e) {
      errorMessage = e.message;
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
      createdAt: post.createdAt,
      communityPostType: post.communityPostType,
      pictureLocations: post.pictureLocations,
    );
    notifyListeners();
  }

  Future<void> onRefresh() async {
    await searchPosts(
      CommunityPostSearchRequestApiModel(
        title: searchController.text.isNotEmpty ? searchController.text : null,
        userUuid: _currentUserUuidForSearch,
        pageNumber: 1,
        pageSize: 5,
        orderBy: 'CreatedAt:desc',
      ),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    onSessionExpired = null;
    onForbidden = null;
    super.dispose();
  }
}

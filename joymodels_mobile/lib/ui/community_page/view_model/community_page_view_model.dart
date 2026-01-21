import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post/response_types/community_post_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/community_post_repository.dart';
import 'package:joymodels_mobile/ui/community_post_create_page/view_model/community_post_create_page_view_model.dart';
import 'package:joymodels_mobile/ui/community_post_create_page/widgets/community_post_create_page_screen.dart';
import 'package:joymodels_mobile/ui/core/mixins/pagination_mixin.dart';
import 'package:provider/provider.dart';

class CommunityPageViewModel extends ChangeNotifier
    with PaginationMixin<CommunityPostResponseApiModel> {
  final communityPostRepository = sl<CommunityPostRepository>();

  final searchController = TextEditingController();

  bool isLoading = false;
  bool isSearching = false;
  bool arePostsLoading = false;

  String? errorMessage;

  PaginationResponseApiModel<CommunityPostResponseApiModel>? posts;

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
        pageSize: 10,
      ),
    );
  }

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    try {
      await searchPosts(
        CommunityPostSearchRequestApiModel(pageNumber: 1, pageSize: 10),
      );
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> searchPosts(CommunityPostSearchRequestApiModel request) async {
    errorMessage = null;
    arePostsLoading = true;
    notifyListeners();

    try {
      posts = await communityPostRepository.search(request);
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
        pageSize: 10,
      ),
    );
  }

  void onCreatePostPressed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => CommunityPostCreatePageViewModel(),
          child: const CommunityPostCreatePageScreen(),
        ),
      ),
    );
  }

  void onPostTap(BuildContext context, CommunityPostResponseApiModel post) {
    // TODO: Navigate to post detail page
  }

  void onUserTap(BuildContext context, String userUuid) {
    // TODO: Navigate to user profile
  }

  Future<void> onRefresh() async {
    await searchPosts(
      CommunityPostSearchRequestApiModel(
        title: searchController.text.isNotEmpty ? searchController.text : null,
        pageNumber: 1,
        pageSize: 10,
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

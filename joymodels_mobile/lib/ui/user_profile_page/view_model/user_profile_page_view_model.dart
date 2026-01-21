import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/model/users/request_types/user_follower_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/users/request_types/user_model_likes_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/users/response_types/user_follower_response_api_model.dart';
import 'package:joymodels_mobile/data/model/users/response_types/user_following_response_api_model.dart';
import 'package:joymodels_mobile/data/model/users/response_types/user_model_likes_search_response_api_model.dart';
import 'package:joymodels_mobile/data/model/users/response_types/users_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/users_repository.dart';

class UserProfilePageViewModel with ChangeNotifier {
  final _usersRepository = sl<UsersRepository>();

  bool isLoading = false;
  bool isLikedModelsLoading = false;
  bool isFollowLoading = false;
  bool isOwnProfile = false;
  bool isFollowing = false;

  UsersResponseApiModel? user;
  Uint8List? userAvatar;

  PaginationResponseApiModel<UserModelLikesSearchResponseApiModel>? likedModels;

  int currentLikedModelsPage = 1;
  static const int _pageSize = 4;

  bool isFollowModalLoading = false;
  String? followModalErrorMessage;
  PaginationResponseApiModel<UserFollowingResponseApiModel>? followingList;
  PaginationResponseApiModel<UserFollowerResponseApiModel>? followersList;
  int currentFollowModalPage = 1;
  String followModalSearchQuery = '';
  final TextEditingController followModalSearchController =
      TextEditingController();
  static const int _followModalPageSize = 10;

  String? errorMessage;

  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;

  int get totalLikedModelsPages => likedModels?.totalPages ?? 1;
  bool get hasLikedModelsPreviousPage => currentLikedModelsPage > 1;
  bool get hasLikedModelsNextPage =>
      currentLikedModelsPage < totalLikedModelsPages;

  Future<void> init(String userUuid) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final loggedUserUuid = await TokenStorage.getCurrentUserUuid();
      isOwnProfile = loggedUserUuid == userUuid;

      await _loadUserData(userUuid);
      await _loadUserAvatar(userUuid);
      await _loadLikedModels(userUuid);

      if (!isOwnProfile) {
        await _checkIfFollowing(userUuid);
      }

      isLoading = false;
      notifyListeners();
    } on SessionExpiredException {
      errorMessage = 'Session expired. Please login again.';
      isLoading = false;
      notifyListeners();
      onSessionExpired?.call();
    } on ForbiddenException {
      isLoading = false;
      notifyListeners();
      onForbidden?.call();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserData(String userUuid) async {
    user = await _usersRepository.getByUuid(userUuid);
  }

  Future<void> _loadUserAvatar(String userUuid) async {
    try {
      final avatar = await _usersRepository.getUserAvatar(userUuid);
      userAvatar = avatar.fileBytes;
    } catch (_) {
      userAvatar = null;
    }
  }

  Future<void> _loadLikedModels(String userUuid) async {
    isLikedModelsLoading = true;
    notifyListeners();

    try {
      final request = UserModelLikesSearchRequestApiModel(
        userUuid: userUuid,
        pageNumber: currentLikedModelsPage,
        pageSize: _pageSize,
      );

      likedModels = await _usersRepository.searchUserModelLikes(request);
      isLikedModelsLoading = false;
      notifyListeners();
    } on SessionExpiredException {
      errorMessage = 'Session expired. Please login again.';
      isLikedModelsLoading = false;
      notifyListeners();
      onSessionExpired?.call();
    } on ForbiddenException {
      isLikedModelsLoading = false;
      notifyListeners();
      onForbidden?.call();
    } catch (e) {
      errorMessage = e.toString();
      isLikedModelsLoading = false;
      notifyListeners();
    }
  }

  Future<void> _checkIfFollowing(String userUuid) async {
    try {
      isFollowing = await _usersRepository.isFollowingUser(userUuid);
    } catch (_) {
      isFollowing = false;
    }
  }

  Future<void> toggleFollow() async {
    if (user == null || isFollowLoading) return;

    isFollowLoading = true;
    notifyListeners();

    try {
      if (isFollowing) {
        await _usersRepository.unfollowAnUser(user!.uuid);
        isFollowing = false;
        user = user!.copyWith(userFollowerCount: user!.userFollowerCount - 1);
      } else {
        await _usersRepository.followAnUser(user!.uuid);
        isFollowing = true;
        user = user!.copyWith(userFollowerCount: user!.userFollowerCount + 1);
      }
      isFollowLoading = false;
      notifyListeners();
    } on SessionExpiredException {
      errorMessage = 'Session expired. Please login again.';
      isFollowLoading = false;
      notifyListeners();
      onSessionExpired?.call();
    } on ForbiddenException {
      isFollowLoading = false;
      notifyListeners();
      onForbidden?.call();
    } catch (e) {
      errorMessage = e.toString();
      isFollowLoading = false;
      notifyListeners();
    }
  }

  Future<void> onLikedModelsPreviousPage() async {
    if (!hasLikedModelsPreviousPage || user == null) return;
    currentLikedModelsPage--;
    await _loadLikedModels(user!.uuid);
  }

  Future<void> onLikedModelsNextPage() async {
    if (!hasLikedModelsNextPage || user == null) return;
    currentLikedModelsPage++;
    await _loadLikedModels(user!.uuid);
  }

  void onBackPressed(BuildContext context) {
    Navigator.of(context).pop();
  }

  int get totalFollowingPages => followingList?.totalPages ?? 1;
  int get totalFollowersPages => followersList?.totalPages ?? 1;
  bool get hasFollowModalPreviousPage => currentFollowModalPage > 1;
  bool get hasFollowingNextPage => currentFollowModalPage < totalFollowingPages;
  bool get hasFollowersNextPage => currentFollowModalPage < totalFollowersPages;

  Future<void> loadFollowingUsers({bool resetPage = false}) async {
    if (user == null) return;

    if (resetPage) {
      currentFollowModalPage = 1;
    }

    isFollowModalLoading = true;
    followModalErrorMessage = null;
    notifyListeners();

    try {
      final request = UserFollowerSearchRequestApiModel(
        targetUserUuid: user!.uuid,
        nickname: followModalSearchQuery.isNotEmpty
            ? followModalSearchQuery
            : null,
        pageNumber: currentFollowModalPage,
        pageSize: _followModalPageSize,
      );

      followingList = await _usersRepository.searchFollowingUsers(request);
      isFollowModalLoading = false;
      notifyListeners();
    } on SessionExpiredException {
      followModalErrorMessage = 'Session expired. Please login again.';
      isFollowModalLoading = false;
      notifyListeners();
      onSessionExpired?.call();
    } on ForbiddenException {
      isFollowModalLoading = false;
      notifyListeners();
      onForbidden?.call();
    } catch (e) {
      followModalErrorMessage = e.toString();
      isFollowModalLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFollowerUsers({bool resetPage = false}) async {
    if (user == null) return;

    if (resetPage) {
      currentFollowModalPage = 1;
    }

    isFollowModalLoading = true;
    followModalErrorMessage = null;
    notifyListeners();

    try {
      final request = UserFollowerSearchRequestApiModel(
        targetUserUuid: user!.uuid,
        nickname: followModalSearchQuery.isNotEmpty
            ? followModalSearchQuery
            : null,
        pageNumber: currentFollowModalPage,
        pageSize: _followModalPageSize,
      );

      followersList = await _usersRepository.searchFollowerUsers(request);
      isFollowModalLoading = false;
      notifyListeners();
    } on SessionExpiredException {
      followModalErrorMessage = 'Session expired. Please login again.';
      isFollowModalLoading = false;
      notifyListeners();
      onSessionExpired?.call();
    } on ForbiddenException {
      isFollowModalLoading = false;
      notifyListeners();
      onForbidden?.call();
    } catch (e) {
      followModalErrorMessage = e.toString();
      isFollowModalLoading = false;
      notifyListeners();
    }
  }

  void onFollowModalSearchChanged(String query, {required bool isFollowing}) {
    followModalSearchQuery = query;
    if (isFollowing) {
      loadFollowingUsers(resetPage: true);
    } else {
      loadFollowerUsers(resetPage: true);
    }
  }

  Future<void> onFollowModalPreviousPage({required bool isFollowing}) async {
    if (!hasFollowModalPreviousPage) return;
    currentFollowModalPage--;
    if (isFollowing) {
      await loadFollowingUsers();
    } else {
      await loadFollowerUsers();
    }
  }

  Future<void> onFollowModalNextPage({required bool isFollowing}) async {
    if (isFollowing && !hasFollowingNextPage) return;
    if (!isFollowing && !hasFollowersNextPage) return;
    currentFollowModalPage++;
    if (isFollowing) {
      await loadFollowingUsers();
    } else {
      await loadFollowerUsers();
    }
  }

  void resetFollowModalState() {
    followingList = null;
    followersList = null;
    currentFollowModalPage = 1;
    followModalSearchQuery = '';
    followModalSearchController.clear();
    followModalErrorMessage = null;
  }

  @override
  void dispose() {
    followModalSearchController.dispose();
    onSessionExpired = null;
    onForbidden = null;
    super.dispose();
  }
}

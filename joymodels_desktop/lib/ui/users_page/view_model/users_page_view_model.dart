import 'package:flutter/material.dart';
import 'package:joymodels_desktop/core/di/di.dart';
import 'package:joymodels_desktop/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/network_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_desktop/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_desktop/data/model/sso/request_types/sso_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/sso/response_types/sso_user_response_api_model.dart';
import 'package:joymodels_desktop/data/model/users/request_types/user_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/users/response_types/users_response_api_model.dart';
import 'package:joymodels_desktop/data/repositories/sso_repository.dart';
import 'package:joymodels_desktop/data/repositories/users_repository.dart';
import 'package:joymodels_desktop/ui/core/view_model/regex_view_model.dart';

class UsersPageViewModel with ChangeNotifier {
  final _usersRepository = sl<UsersRepository>();
  final _ssoRepository = sl<SsoRepository>();

  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;

  bool _isInitialized = false;

  PaginationResponseApiModel<UsersResponseApiModel>? verifiedPagination;
  bool isLoadingVerified = false;
  String verifiedSearchQuery = '';

  PaginationResponseApiModel<SsoUserResponseApiModel>? unverifiedPagination;
  bool isLoadingUnverified = false;
  String unverifiedSearchNickname = '';
  String unverifiedSearchEmail = '';

  String? errorMessage;

  String? verifiedSearchError;
  String? unverifiedNicknameError;
  String? unverifiedEmailError;

  static const int _pageSize = 10;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await Future.wait([searchVerifiedUsers(), searchUnverifiedUsers()]);
  }

  void clearErrorMessage() {
    errorMessage = null;
    notifyListeners();
  }

  void setVerifiedSearchQuery(String query) {
    verifiedSearchQuery = query;
    verifiedSearchError = query.isEmpty
        ? null
        : RegexValidationViewModel.validateText(query);
    notifyListeners();
  }

  Future<void> searchVerifiedUsers({int page = 1}) async {
    isLoadingVerified = true;
    errorMessage = null;
    notifyListeners();

    try {
      final request = UsersSearchRequestApiModel(
        nickname: verifiedSearchQuery.isNotEmpty ? verifiedSearchQuery : null,
        pageNumber: page,
        pageSize: _pageSize,
      );

      verifiedPagination = await _usersRepository.search(request);
      isLoadingVerified = false;
      notifyListeners();
    } on SessionExpiredException {
      isLoadingVerified = false;
      notifyListeners();
      onSessionExpired?.call();
    } on ForbiddenException {
      isLoadingVerified = false;
      notifyListeners();
      onForbidden?.call();
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isLoadingVerified = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load verified users.';
      isLoadingVerified = false;
      notifyListeners();
    }
  }

  void setUnverifiedSearchNickname(String query) {
    unverifiedSearchNickname = query;
    unverifiedNicknameError = query.isEmpty
        ? null
        : RegexValidationViewModel.validateText(query);
    notifyListeners();
  }

  void setUnverifiedSearchEmail(String query) {
    unverifiedSearchEmail = query;
    unverifiedEmailError = query.isEmpty
        ? null
        : RegexValidationViewModel.validateText(query);
    notifyListeners();
  }

  Future<void> searchUnverifiedUsers({int page = 1}) async {
    isLoadingUnverified = true;
    errorMessage = null;
    notifyListeners();

    try {
      final request = SsoSearchRequestApiModel(
        nickname: unverifiedSearchNickname.isNotEmpty
            ? unverifiedSearchNickname
            : null,
        email: unverifiedSearchEmail.isNotEmpty ? unverifiedSearchEmail : null,
        pageNumber: page,
        pageSize: _pageSize,
      );

      unverifiedPagination = await _ssoRepository.search(request);
      isLoadingUnverified = false;
      notifyListeners();
    } on SessionExpiredException {
      isLoadingUnverified = false;
      notifyListeners();
      onSessionExpired?.call();
    } on ForbiddenException {
      isLoadingUnverified = false;
      notifyListeners();
      onForbidden?.call();
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isLoadingUnverified = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load unverified users.';
      isLoadingUnverified = false;
      notifyListeners();
    }
  }

  Future<void> deleteVerifiedUser(String userUuid) async {
    try {
      await _usersRepository.delete(userUuid);
      await searchVerifiedUsers(page: verifiedPagination?.pageNumber ?? 1);
    } on SessionExpiredException {
      onSessionExpired?.call();
    } on ForbiddenException {
      onForbidden?.call();
    } on NetworkException {
      errorMessage = NetworkException().toString();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to delete user.';
      notifyListeners();
    }
  }

  Future<void> deleteUnverifiedUser(String userUuid) async {
    try {
      await _ssoRepository.delete(userUuid);
      await searchUnverifiedUsers(page: unverifiedPagination?.pageNumber ?? 1);
    } on SessionExpiredException {
      onSessionExpired?.call();
    } on ForbiddenException {
      onForbidden?.call();
    } on NetworkException {
      errorMessage = NetworkException().toString();
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to delete user.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    onSessionExpired = null;
    onForbidden = null;
    super.dispose();
  }
}

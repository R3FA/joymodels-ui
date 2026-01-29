import 'package:flutter/material.dart';
import 'package:joymodels_desktop/core/di/di.dart';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';
import 'package:joymodels_desktop/data/core/exceptions/api_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/network_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_desktop/data/model/sso/request_types/sso_logout_request_api_model.dart';
import 'package:joymodels_desktop/data/repositories/sso_repository.dart';

class HomePageScreenViewModel with ChangeNotifier {
  final _ssoRepository = sl<SsoRepository>();

  int selectedIndex = 0;
  int usersInitialTabIndex = 0;

  String? currentUserName;
  String? userUuid;
  bool isLoading = true;

  VoidCallback? onLogoutSuccess;
  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;
  VoidCallback? onNetworkError;

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    userUuid = await TokenStorage.getCurrentUserUuid();
    currentUserName = await TokenStorage.getCurrentUserName();

    isLoading = false;
    notifyListeners();
  }

  void setSelectedIndex(int index) {
    if (index != 1) usersInitialTabIndex = 0;
    selectedIndex = index;
    notifyListeners();
  }

  void navigateToUsers({int tabIndex = 0}) {
    usersInitialTabIndex = tabIndex;
    selectedIndex = 1;
    notifyListeners();
  }

  void navigateToCategories() {
    selectedIndex = 2;
    notifyListeners();
  }

  void navigateToReports() {
    selectedIndex = 3;
    notifyListeners();
  }

  Future<void> logout() async {
    final refreshToken = await TokenStorage.getRefreshToken();

    if (userUuid == null || refreshToken == null) return;

    try {
      await _ssoRepository.logout(
        SsoLogoutRequestApiModel(
          userUuid: userUuid!,
          userRefreshToken: refreshToken,
        ),
      );

      await TokenStorage.clearAuthToken();
      onLogoutSuccess?.call();
    } on SessionExpiredException {
      onSessionExpired?.call();
    } on ForbiddenException {
      onForbidden?.call();
    } on NetworkException {
      onNetworkError?.call();
    } on ApiException {
      // API error during logout — silently ignore
    }
  }

  @override
  void dispose() {
    onLogoutSuccess = null;
    onSessionExpired = null;
    onForbidden = null;
    onNetworkError = null;
    super.dispose();
  }
}

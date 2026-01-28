import 'package:flutter/material.dart';
import 'package:joymodels_desktop/core/di/di.dart';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';
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
  bool isLoggingOut = false;
  String? errorMessage;

  VoidCallback? onLogoutSuccess;
  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;

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

  void clearErrorMessage() {
    errorMessage = null;
    notifyListeners();
  }

  Future<void> logout() async {
    final refreshToken = await TokenStorage.getRefreshToken();

    if (userUuid == null || refreshToken == null) return;

    isLoggingOut = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _ssoRepository.logout(
        SsoLogoutRequestApiModel(
          userUuid: userUuid!,
          userRefreshToken: refreshToken,
        ),
      );

      await TokenStorage.clearAuthToken();
      isLoggingOut = false;
      notifyListeners();

      onLogoutSuccess?.call();
    } on SessionExpiredException {
      isLoggingOut = false;
      notifyListeners();
      onSessionExpired?.call();
    } on ForbiddenException {
      isLoggingOut = false;
      notifyListeners();
      onForbidden?.call();
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isLoggingOut = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Logout failed. Please try again.';
      isLoggingOut = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    onLogoutSuccess = null;
    onSessionExpired = null;
    onForbidden = null;
    super.dispose();
  }
}

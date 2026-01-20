import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_logout_request_api_model.dart';
import 'package:joymodels_mobile/data/repositories/sso_repository.dart';
import 'package:joymodels_mobile/ui/settings_page/widgets/settings_page_screen.dart';

class MenuDrawerViewModel with ChangeNotifier {
  final _ssoRepository = sl<SsoRepository>();

  bool isLoggingOut = false;
  String? userUuid;
  String? userName;
  String? errorMessage;

  VoidCallback? onLogoutSuccess;

  Future<void> init() async {
    userUuid = await TokenStorage.getCurrentUserUuid();
    userName = await TokenStorage.getCurrentUserName();
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
    } catch (e) {
      errorMessage = 'Logout failed. Please try again.';
      isLoggingOut = false;
      notifyListeners();
    }
  }

  void navigateToLibrary(BuildContext context) {
    Navigator.of(context).pop();
    // TODO: Navigate to Library page
  }

  void navigateToSettings(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsPageScreen()));
  }

  void navigateToUserProfile(BuildContext context) {
    Navigator.of(context).pop();
    // TODO: Navigate to User Profile page
  }

  @override
  void dispose() {
    onLogoutSuccess = null;
    super.dispose();
  }
}

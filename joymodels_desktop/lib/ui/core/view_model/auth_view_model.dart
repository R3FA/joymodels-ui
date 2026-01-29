import 'package:flutter/material.dart';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';
import 'package:joymodels_desktop/ui/core/ui/access_denied_screen.dart';
import 'package:joymodels_desktop/ui/home_page/widgets/home_page_screen.dart';
import 'package:joymodels_desktop/ui/login_page/widgets/login_page_screen.dart';

class AuthViewModel {
  static Future<bool> _checkUserLoginStatus() async {
    return await TokenStorage.hasAuthToken();
  }

  static Future<bool> _checkIsAdminOrRoot() async {
    return await TokenStorage.isAdminOrRoot();
  }

  static Future<Widget> widgetHomePageScreen() async {
    if (!await _checkUserLoginStatus()) {
      return const LoginPageScreen();
    }

    if (!await _checkIsAdminOrRoot()) {
      return const AccessDeniedScreen();
    }

    return const HomePageScreen();
  }
}

import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/ui/home_page/widgets/home_page_screen.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';

class AuthViewModel {
  static Future<bool> _checkUserLoginStatus() async {
    return await TokenStorage.hasAuthToken();
  }

  static Future<Widget> widgetHomePageScreen() async {
    return await _checkUserLoginStatus()
        ? const HomePageScreen()
        : const WelcomePageScreen();
  }
}

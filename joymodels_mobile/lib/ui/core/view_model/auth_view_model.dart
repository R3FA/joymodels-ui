import 'package:flutter/material.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/model/enums/user_role_api_enum.dart';
import 'package:joymodels_mobile/ui/home_page/widgets/home_page_screen.dart';
import 'package:joymodels_mobile/ui/verify_page/widgets/verify_page_screen.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';

class AuthViewModel {
  static Future<bool> _checkUserLoginStatus() async {
    return await TokenStorage.hasAuthToken();
  }

  static Future<UserRoleApiEnum?> _getUserRole() async {
    final roleString = await TokenStorage.getCurrentUserRole();
    if (roleString == null) return null;

    try {
      return UserRoleApiEnum.values.firstWhere(
        (role) => role.name == roleString,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<Widget> widgetHomePageScreen() async {
    if (!await _checkUserLoginStatus()) {
      return const WelcomePageScreen();
    }

    final userRole = await _getUserRole();
    if (userRole == UserRoleApiEnum.Unverified) {
      return const VerifyPageScreen();
    }

    return const HomePageScreen();
  }
}

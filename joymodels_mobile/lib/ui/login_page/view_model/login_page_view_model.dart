import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/core/exceptions/network_exception.dart';
import 'package:joymodels_mobile/data/model/enums/jwt_claim_key_api_enum.dart';
import 'package:joymodels_mobile/data/model/enums/user_role_api_enum.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_user_login_request_api_model.dart';
import 'package:joymodels_mobile/data/repositories/sso_repository.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';
import 'package:joymodels_mobile/ui/core/ui/navigation_bar/view_model/navigation_bar_view_model.dart';
import 'package:joymodels_mobile/ui/home_page/widgets/home_page_screen.dart';
import 'package:joymodels_mobile/ui/verify_page/widgets/verify_page_screen.dart';
import 'package:provider/provider.dart';

class LoginPageScreenViewModel with ChangeNotifier {
  final ssoRepository = sl<SsoRepository>();

  final formKey = GlobalKey<FormState>();

  final nicknameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  String? errorMessage;
  String? successMessage;

  String? validateNickname(String? nickname) {
    return RegexValidationViewModel.validateNickname(nickname);
  }

  String? validatePassword(String? password) {
    return RegexValidationViewModel.validatePassword(password);
  }

  void clearControllers() {
    nicknameController.clear();
    passwordController.clear();
    isLoading = false;
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }

  Future<bool> login(BuildContext context) async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    if (!formKey.currentState!.validate()) {
      isLoading = false;
      notifyListeners();
      return false;
    }

    final SsoUserLoginRequestApiModel request = SsoUserLoginRequestApiModel(
      nickname: nicknameController.text,
      password: passwordController.text,
    );

    try {
      final loginResponse = await ssoRepository.login(request);

      await TokenStorage.setNewAuthToken(
        loginResponse.accessToken,
        loginResponse.refreshToken,
      );

      successMessage = 'Login successful! Redirecting...';
      notifyListeners();
      await Future.delayed(const Duration(seconds: 2));

      if (await TokenStorage.getClaimFromToken(JwtClaimKeyApiEnum.role) ==
          UserRoleApiEnum.Unverified.name) {
        if (context.mounted) {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => VerifyPageScreen()));
        }
      } else {
        if (context.mounted) {
          await context.read<NavigationBarViewModel>().refreshAdminStatus();
          if (context.mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePageScreen()),
            );
          }
        }
      }
      clearControllers();
      return true;
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Incorrect username or password!';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    nicknameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:joymodels_desktop/core/di/di.dart';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';
import 'package:joymodels_desktop/data/core/exceptions/api_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/network_exception.dart';
import 'package:joymodels_desktop/data/model/sso/request_types/sso_user_login_request_api_model.dart';
import 'package:joymodels_desktop/data/repositories/sso_repository.dart';
import 'package:joymodels_desktop/ui/core/view_model/regex_view_model.dart';
import 'package:joymodels_desktop/ui/home_page/widgets/home_page_screen.dart';

class LoginPageScreenViewModel with ChangeNotifier {
  final ssoRepository = sl<SsoRepository>();

  final formKey = GlobalKey<FormState>();

  final nicknameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool _isDisposed = false;

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
      final loginResponse = await ssoRepository.adminLogin(request);

      await TokenStorage.setNewAuthToken(
        loginResponse.accessToken,
        loginResponse.refreshToken,
      );

      successMessage = 'Login successful! Redirecting...';
      notifyListeners();

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePageScreen()),
        );
      }

      clearControllers();
      return true;
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isLoading = false;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    nicknameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }
}

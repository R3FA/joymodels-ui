import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_user_login_request_api_model.dart';
import 'package:joymodels_mobile/data/repositories/sso_repository.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';

class LoginPageScreenViewModel with ChangeNotifier {
  final ssoRepository = sl<SsoRepository>();
  final formKey = GlobalKey<FormState>();
  final nicknameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  String? validateNickname(String? nickname) {
    return RegexValidationViewModel.validateNickname(nickname);
  }

  String? validatePassword(String? password) {
    return RegexValidationViewModel.validatePassword(password);
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

      isLoading = false;
      errorMessage = null;
      notifyListeners();
      await TokenStorage.saveAccessToken(loginResponse.accessToken);
      // final accessTokenPayloadMap = TokenStorage.decodeAccessToken(
      //   loginResponse.accessToken,
      // );

      // if (context.mounted) {
      //   Navigator.of(context).pushReplacement(
      //     MaterialPageRoute(builder: (context) => WelcomePageScreen()),
      //   );
      // }

      return true;
    } catch (e) {
      errorMessage = e.toString();
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

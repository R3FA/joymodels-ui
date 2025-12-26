import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/model/enums/jwt_claim_key_api_enum.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_new_otp_code_request_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_verify_request_api_model.dart';
import 'package:joymodels_mobile/data/repositories/sso_repository.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';
import 'package:joymodels_mobile/ui/home_page/widgets/home_page_screen.dart';

class VerifyPageScreenViewModel with ChangeNotifier {
  final ssoRepository = sl<SsoRepository>();
  final formKey = GlobalKey<FormState>();
  final otpCodeController = TextEditingController();

  bool isVerifying = false;
  bool isRequestingNewOtpCode = false;

  String? errorMessage;
  String? successMessage;

  String? validateOtpCode(String? otpCode) {
    return RegexValidationViewModel.validateOtpCode(otpCode);
  }

  Future<bool> verify(BuildContext context) async {
    errorMessage = null;
    successMessage = null;
    isVerifying = true;
    notifyListeners();

    if (!formKey.currentState!.validate()) {
      isVerifying = false;
      notifyListeners();
      return false;
    }

    final accessTokenPayloadMap = TokenStorage.decodeAccessToken(
      (await TokenStorage.getAccessToken())!,
    );

    final SsoVerifyRequestApiModel request = SsoVerifyRequestApiModel(
      userUuid: accessTokenPayloadMap[JwtClaimKeyApiEnum.nameIdentifier.key],
      otpCode: otpCodeController.text,
      userRefreshToken: (await TokenStorage.getRefreshToken())!,
    );

    try {
      final ssoUserResponse = await ssoRepository.verify(request);
      isVerifying = false;
      errorMessage = null;
      TokenStorage.setNewAccessToken(ssoUserResponse.userAccessToken!);
      successMessage = "User successfully verified. Logging in...";
      await Future.delayed(Duration(seconds: 2));
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => HomePageScreen()),
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isVerifying = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> requestNewOtpCode() async {
    errorMessage = null;
    successMessage = null;
    isRequestingNewOtpCode = true;
    notifyListeners();

    final accessTokenPayloadMap = TokenStorage.decodeAccessToken(
      (await TokenStorage.getAccessToken())!,
    );

    final SsoNewOtpCodeRequestApiModel request = SsoNewOtpCodeRequestApiModel(
      userUuid: accessTokenPayloadMap[JwtClaimKeyApiEnum.nameIdentifier.key],
    );

    try {
      await ssoRepository.requestNewOtpCode(request);
      isRequestingNewOtpCode = false;
      errorMessage = null;
      successMessage = "New OTP Code has been sent!";
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      isRequestingNewOtpCode = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    otpCodeController.dispose();
    super.dispose();
  }
}

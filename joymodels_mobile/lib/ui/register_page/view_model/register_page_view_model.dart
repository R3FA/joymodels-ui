import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_user_create_request_api_model.dart';
import 'package:joymodels_mobile/data/repositories/sso_repository.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';
import 'package:joymodels_mobile/ui/core/view_model/user_profile_picture_view_model.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';

class RegisterPageScreenViewModel with ChangeNotifier {
  final ssoRepository = sl<SsoRepository>();

  bool isLoading = false;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final nicknameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  File? userProfilePicture;

  String? profilePictureErrorMessage;
  String? responseErrorMessage;

  // Form field validations
  String? validateName(String? name) {
    return RegexValidationViewModel.validateName(name);
  }

  String? validateNickname(String? nickname) {
    return RegexValidationViewModel.validateNickname(nickname);
  }

  String? validateEmail(String? email) {
    return RegexValidationViewModel.validateEmail(email);
  }

  String? validatePassword(String? password) {
    return RegexValidationViewModel.validatePassword(password);
  }

  Future<String?> validateUserPicture(File? file) async {
    return profilePictureErrorMessage =
        await UserProfilePictureValidationViewModel.validateUserPicture(file);
  }

  Future<void> pickUserProfilePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      userProfilePicture = File(picked.path);
      notifyListeners();
    }
  }

  Future<bool> submitForm(BuildContext context) async {
    responseErrorMessage = null;
    isLoading = true;
    notifyListeners();

    profilePictureErrorMessage = await validateUserPicture(userProfilePicture);

    if (profilePictureErrorMessage != null) {
      isLoading = false;
      notifyListeners();
      return false;
    }

    final SsoUserCreateRequestApiModel domainModel =
        SsoUserCreateRequestApiModel(
          firstName: firstNameController.text,
          lastName: lastNameController.text.isNotEmpty
              ? lastNameController.text
              : null,
          nickname: nicknameController.text,
          email: emailController.text,
          password: passwordController.text,
          userPicture: userProfilePicture!,
        );

    try {
      await ssoRepository.createUser(domainModel);

      isLoading = false;
      responseErrorMessage = null;
      notifyListeners();
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => WelcomePageScreen()),
        );
      }
      return true;
    } catch (e) {
      responseErrorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void disposeControllers() {
    firstNameController.dispose();
    lastNameController.dispose();
    nicknameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_user_create_request_api_model.dart';
import 'package:joymodels_mobile/data/repositories/sso_repository.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';
import 'package:joymodels_mobile/ui/core/view_model/validation_view_model.dart';
import 'package:joymodels_mobile/ui/welcome_page/widgets/welcome_page_screen.dart';

class RegisterPageScreenViewModel with ChangeNotifier {
  final ssoRepository = sl<SsoRepository>();

  final formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final nicknameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  File? userProfilePicture;

  bool isLoading = false;

  String? profilePictureErrorMessage;
  String? responseErrorMessage;
  String? successMessage;

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
        await ValidationViewModel.validateUserPicture(file);
  }

  Future<void> pickUserProfilePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      userProfilePicture = File(picked.path);
      notifyListeners();
    }
  }

  void clearControllers() {
    isLoading = false;
    firstNameController.clear();
    lastNameController.clear();
    nicknameController.clear();
    emailController.clear();
    passwordController.clear();
    userProfilePicture = null;
    profilePictureErrorMessage = null;
    responseErrorMessage = null;
    successMessage = null;
    notifyListeners();
  }

  Future<bool> submitForm(BuildContext context) async {
    responseErrorMessage = null;
    isLoading = true;
    notifyListeners();

    if (!formKey.currentState!.validate()) {
      isLoading = false;
      notifyListeners();
      return false;
    }

    profilePictureErrorMessage = await validateUserPicture(userProfilePicture);
    if (profilePictureErrorMessage != null) {
      isLoading = false;
      notifyListeners();
      return false;
    }

    final SsoUserCreateRequestApiModel request = SsoUserCreateRequestApiModel(
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
      await ssoRepository.create(request);

      successMessage =
          'Registration successful! Redirecting to welcome page...';
      notifyListeners();
      await Future.delayed(const Duration(seconds: 3));

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => WelcomePageScreen()),
        );
      }

      clearControllers();
      return true;
    } catch (e) {
      responseErrorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    nicknameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

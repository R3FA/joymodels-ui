import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';
import 'package:joymodels_mobile/ui/core/view_model/user_profile_picture_view_model.dart';

class RegisterPageScreenViewModel with ChangeNotifier {
  bool isLoading = false;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final nicknameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  File? userProfilePicture;

  String? userProfilePictureError;
  String? submitError;

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

  Future<void> pickUserProfilePicture() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      userProfilePicture = File(picked.path);
      notifyListeners();
    }
  }

  void setProfilePicture(File? file) {
    userProfilePicture = file;
    notifyListeners();
  }

  Future<String?> validateUserPicture(File? file) async {
    userProfilePictureError =
        await UserProfilePictureValidationViewModel.validateUserPicture(file);

    notifyListeners();

    return userProfilePictureError;
  }

  // TODO: Kada napravis servise, repo, domain klase itd onda ovu metodu zavrsi
  Future<bool> submitForm(BuildContext context) async {
    await validateUserPicture(userProfilePicture);

    // submitError = null;
    // isLoading = true;
    // notifyListeners();

    // await Future.delayed(const Duration(milliseconds: 5000));

    // isLoading = false;
    // notifyListeners();

    return true;
  }

  void disposeControllers() {
    super.dispose();
  }
}

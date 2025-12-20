import 'package:flutter/material.dart';
import 'dart:io';

import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';

class RegisterPageScreenViewModel with ChangeNotifier {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final nicknameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  File? avatarImage;

  String? avatarError;

  bool isLoading = false;
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

  // Upload avatara
  String? setAvatar(File? file) {
    avatarImage = file;
    avatarError = (file == null) ? 'Avatar is required' : null;
    notifyListeners();
  }

  // SUBMIT
  Future<bool> submitForm(BuildContext context) async {
    submitError = null;
    avatarError = (avatarImage == null) ? 'Avatar is required' : null;
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700)); // simulate API

    isLoading = false;
    notifyListeners();

    // Validacija za avatar
    if (avatarError != null) {
      submitError = null; // poništi prethodnu grešku
      notifyListeners();
      return false;
    }
    // success example
    return true;
  }

  void disposeControllers() {
    super.dispose();
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/network_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_logout_request_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_password_change_request_api_model.dart';
import 'package:joymodels_mobile/data/model/users/request_types/users_patch_request_api_model.dart';
import 'package:joymodels_mobile/data/model/users/response_types/users_response_api_model.dart';
import 'package:joymodels_mobile/data/core/repositories/auth_repository.dart';
import 'package:joymodels_mobile/data/repositories/sso_repository.dart';
import 'package:joymodels_mobile/data/repositories/users_repository.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';
import 'package:joymodels_mobile/ui/core/view_model/validation_view_model.dart';

class SettingsPageViewModel with ChangeNotifier {
  final _usersRepository = sl<UsersRepository>();
  final _ssoRepository = sl<SsoRepository>();
  final _authRepository = sl<AuthRepository>();
  final _imagePicker = ImagePicker();

  late final TextEditingController firstNameController;
  late final TextEditingController lastNameController;
  late final TextEditingController nicknameController;

  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  SettingsPageViewModel() {
    firstNameController = TextEditingController()..addListener(_onTextChanged);
    lastNameController = TextEditingController()..addListener(_onTextChanged);
    nicknameController = TextEditingController()..addListener(_onTextChanged);
    newPasswordController = TextEditingController()
      ..addListener(_onTextChanged);
    confirmPasswordController = TextEditingController()
      ..addListener(_onTextChanged);
  }

  void _onTextChanged() {
    notifyListeners();
  }

  bool isLoading = false;
  bool isSaving = false;
  bool isChangingPassword = false;

  String? userUuid;
  UsersResponseApiModel? currentUser;
  String? selectedImagePath;

  String? errorMessage;
  String? successMessage;

  String? _originalFirstName;
  String? _originalLastName;
  String? _originalNickname;

  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;
  VoidCallback? onProfileSaved;

  bool get hasProfileChanges {
    if (selectedImagePath != null) return true;
    if (_originalFirstName == null) return false;

    return firstNameController.text != _originalFirstName ||
        lastNameController.text != (_originalLastName ?? '') ||
        nicknameController.text != _originalNickname;
  }

  bool get canChangePassword {
    return newPasswordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty;
  }

  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      userUuid = await TokenStorage.getCurrentUserUuid();

      if (userUuid != null) {
        currentUser = await _usersRepository.getByUuid(userUuid!);

        firstNameController.text = currentUser!.firstName;
        lastNameController.text = currentUser!.lastName ?? '';
        nicknameController.text = currentUser!.nickName;

        _originalFirstName = currentUser!.firstName;
        _originalLastName = currentUser!.lastName;
        _originalNickname = currentUser!.nickName;
      }

      isLoading = false;
      notifyListeners();
    } on SessionExpiredException {
      errorMessage = 'Session expired. Please login again.';
      isLoading = false;
      notifyListeners();
      onSessionExpired?.call();
    } on ForbiddenException {
      isLoading = false;
      notifyListeners();
      onForbidden?.call();
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final validationError =
          await ValidationViewModel.validateUserPictureOptional(file);

      if (validationError != null) {
        errorMessage = validationError;
        notifyListeners();
        return;
      }

      errorMessage = null;
      selectedImagePath = pickedFile.path;
      notifyListeners();
    }
  }

  Future<void> saveProfile() async {
    if (userUuid == null) return;

    errorMessage = null;
    successMessage = null;

    if (!hasProfileChanges) {
      errorMessage = 'No changes detected. Please modify at least one field.';
      notifyListeners();
      return;
    }

    if (firstNameController.text.isEmpty) {
      errorMessage = 'First name is required.';
      notifyListeners();
      return;
    }

    final firstNameError = RegexValidationViewModel.validateName(
      firstNameController.text,
    );
    if (firstNameError != null) {
      errorMessage = firstNameError;
      notifyListeners();
      return;
    }

    if (lastNameController.text.isEmpty) {
      errorMessage = 'Last name is required.';
      notifyListeners();
      return;
    }

    final lastNameError = RegexValidationViewModel.validateName(
      lastNameController.text,
    );
    if (lastNameError != null) {
      errorMessage = lastNameError;
      notifyListeners();
      return;
    }

    if (nicknameController.text.isEmpty) {
      errorMessage = 'Nickname is required.';
      notifyListeners();
      return;
    }

    final nicknameError = RegexValidationViewModel.validateNickname(
      nicknameController.text,
    );
    if (nicknameError != null) {
      errorMessage = nicknameError;
      notifyListeners();
      return;
    }

    if (selectedImagePath != null) {
      final file = File(selectedImagePath!);
      final imageError = await ValidationViewModel.validateUserPictureOptional(
        file,
      );
      if (imageError != null) {
        errorMessage = imageError;
        notifyListeners();
        return;
      }
    }

    isSaving = true;
    notifyListeners();

    try {
      final request = UsersPatchRequestApiModel(
        userUuid: userUuid!,
        firstName: firstNameController.text != _originalFirstName
            ? firstNameController.text
            : null,
        lastName: lastNameController.text != (_originalLastName ?? '')
            ? lastNameController.text
            : null,
        nickname: nicknameController.text != _originalNickname
            ? nicknameController.text
            : null,
        userPicturePath: selectedImagePath,
      );

      currentUser = await _usersRepository.editUser(request);

      await _authRepository.requestAccessTokenChange();

      _originalFirstName = currentUser!.firstName;
      _originalLastName = currentUser!.lastName;
      _originalNickname = currentUser!.nickName;

      selectedImagePath = null;
      isSaving = false;
      successMessage = null;
      errorMessage = null;
      notifyListeners();
      onProfileSaved?.call();
    } on SessionExpiredException {
      errorMessage = 'Session expired. Please login again.';
      isSaving = false;
      notifyListeners();
      onSessionExpired?.call();
    } on ForbiddenException {
      isSaving = false;
      notifyListeners();
      onForbidden?.call();
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isSaving = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> changePassword() async {
    if (userUuid == null) return;

    errorMessage = null;
    successMessage = null;

    final newPasswordError = RegexValidationViewModel.validatePassword(
      newPasswordController.text,
    );
    if (newPasswordError != null) {
      errorMessage = newPasswordError;
      notifyListeners();
      return;
    }

    final confirmPasswordError = RegexValidationViewModel.validatePassword(
      confirmPasswordController.text,
    );
    if (confirmPasswordError != null) {
      errorMessage = confirmPasswordError;
      notifyListeners();
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      errorMessage = 'Passwords do not match.';
      notifyListeners();
      return;
    }

    isChangingPassword = true;
    notifyListeners();

    try {
      final request = SsoPasswordChangeRequestApiModel(
        userUuid: userUuid!,
        newPassword: newPasswordController.text,
        confirmNewPassword: confirmPasswordController.text,
      );

      await _ssoRepository.requestPasswordChange(request);

      final refreshToken = await TokenStorage.getRefreshToken();
      if (refreshToken != null) {
        final logoutRequest = SsoLogoutRequestApiModel(
          userUuid: userUuid!,
          userRefreshToken: refreshToken,
        );
        await _ssoRepository.logout(logoutRequest);
      }
      await TokenStorage.clearAuthToken();

      newPasswordController.clear();
      confirmPasswordController.clear();
      isChangingPassword = false;
      notifyListeners();

      onSessionExpired?.call();
    } on SessionExpiredException {
      errorMessage = 'Session expired. Please login again.';
      isChangingPassword = false;
      notifyListeners();
      onSessionExpired?.call();
    } on ForbiddenException {
      isChangingPassword = false;
      notifyListeners();
      onForbidden?.call();
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isChangingPassword = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to change password. Please try again.';
      isChangingPassword = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    nicknameController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    onSessionExpired = null;
    onForbidden = null;
    onProfileSaved = null;
    super.dispose();
  }
}

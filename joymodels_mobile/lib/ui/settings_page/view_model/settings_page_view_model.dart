import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/network_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/api_exception.dart';
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
    clearFieldErrors();
    notifyListeners();
  }

  void clearFieldErrors() {
    firstNameError = null;
    lastNameError = null;
    nicknameError = null;
    newPasswordError = null;
    confirmPasswordError = null;
    deleteConfirmError = null;
  }

  bool isLoading = false;
  bool isSaving = false;
  bool isChangingPassword = false;
  bool isDeletingAccount = false;
  bool isDeleteConfirmed = false;

  String? userUuid;
  UsersResponseApiModel? currentUser;
  String? selectedImagePath;

  String? errorMessage;
  String? successMessage;

  String? firstNameError;
  String? lastNameError;
  String? nicknameError;
  String? newPasswordError;
  String? confirmPasswordError;
  String? deleteConfirmError;

  String? _originalFirstName;
  String? _originalLastName;
  String? _originalNickname;

  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;
  VoidCallback? onProfileSaved;
  VoidCallback? onAccountDeleted;

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
    } on ApiException catch (e) {
      errorMessage = e.message;
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

  bool _isProfileFormValid() {
    clearFieldErrors();
    bool valid = true;

    if (firstNameController.text.isEmpty) {
      firstNameError = 'First name is required.';
      valid = false;
    } else {
      final validation = RegexValidationViewModel.validateName(
        firstNameController.text,
      );
      if (validation != null) {
        firstNameError = validation;
        valid = false;
      }
    }

    if (lastNameController.text.isEmpty) {
      lastNameError = 'Last name is required.';
      valid = false;
    } else {
      final validation = RegexValidationViewModel.validateName(
        lastNameController.text,
      );
      if (validation != null) {
        lastNameError = validation;
        valid = false;
      }
    }

    if (nicknameController.text.isEmpty) {
      nicknameError = 'Nickname is required.';
      valid = false;
    } else {
      final validation = RegexValidationViewModel.validateNickname(
        nicknameController.text,
      );
      if (validation != null) {
        nicknameError = validation;
        valid = false;
      }
    }

    return valid;
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

    if (!_isProfileFormValid()) {
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
    } on ApiException catch (e) {
      errorMessage = e.message;
      isSaving = false;
      notifyListeners();
    }
  }

  bool _isPasswordFormValid() {
    clearFieldErrors();
    bool valid = true;

    final newPwValidation = RegexValidationViewModel.validatePassword(
      newPasswordController.text,
    );
    if (newPwValidation != null) {
      newPasswordError = newPwValidation;
      valid = false;
    }

    final confirmPwValidation = RegexValidationViewModel.validatePassword(
      confirmPasswordController.text,
    );
    if (confirmPwValidation != null) {
      confirmPasswordError = confirmPwValidation;
      valid = false;
    }

    if (valid && newPasswordController.text != confirmPasswordController.text) {
      newPasswordError = 'Passwords do not match.';
      confirmPasswordError = 'Passwords do not match.';
      valid = false;
    }

    return valid;
  }

  Future<void> changePassword() async {
    if (userUuid == null) return;

    errorMessage = null;
    successMessage = null;

    if (!_isPasswordFormValid()) {
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
    } on ApiException catch (e) {
      errorMessage = e.message;
      isChangingPassword = false;
      notifyListeners();
    }
  }

  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    clearFieldErrors();
    notifyListeners();
  }

  void toggleDeleteConfirmation(bool? value) {
    isDeleteConfirmed = value ?? false;
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    if (userUuid == null) return;

    errorMessage = null;
    successMessage = null;

    if (!isDeleteConfirmed) {
      deleteConfirmError =
          'Please confirm that you understand by checking the checkbox.';
      notifyListeners();
      return;
    }

    isDeletingAccount = true;
    notifyListeners();

    try {
      await _usersRepository.delete(userUuid!);

      await TokenStorage.clearAuthToken();

      isDeletingAccount = false;
      isDeleteConfirmed = false;
      notifyListeners();

      onAccountDeleted?.call();
    } on SessionExpiredException {
      errorMessage = 'Session expired. Please login again.';
      isDeletingAccount = false;
      notifyListeners();
      onSessionExpired?.call();
    } on ForbiddenException {
      isDeletingAccount = false;
      notifyListeners();
      onForbidden?.call();
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isDeletingAccount = false;
      notifyListeners();
    } on ApiException catch (e) {
      errorMessage = e.message;
      isDeletingAccount = false;
      notifyListeners();
    }
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
    onAccountDeleted = null;
    super.dispose();
  }
}

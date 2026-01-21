import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_logout_request_api_model.dart';
import 'package:joymodels_mobile/data/model/users/request_types/user_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/users/response_types/users_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/sso_repository.dart';
import 'package:joymodels_mobile/data/repositories/users_repository.dart';
import 'package:joymodels_mobile/ui/core/mixins/pagination_mixin.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';
import 'package:joymodels_mobile/ui/settings_page/widgets/settings_page_screen.dart';
import 'package:joymodels_mobile/ui/user_profile_page/widgets/user_profile_page_screen.dart';

class MenuDrawerViewModel extends ChangeNotifier
    with PaginationMixin<UsersResponseApiModel> {
  final _ssoRepository = sl<SsoRepository>();
  final _usersRepository = sl<UsersRepository>();

  bool isLoggingOut = false;
  String? userUuid;
  String? userName;
  String? errorMessage;

  bool isSearching = false;
  String? searchErrorMessage;
  PaginationResponseApiModel<UsersResponseApiModel>? searchResults;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  static const int _searchPageSize = 10;

  VoidCallback? onLogoutSuccess;
  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;

  @override
  PaginationResponseApiModel<UsersResponseApiModel>? get paginationData =>
      searchResults;

  @override
  bool get isLoadingPage => isSearching;

  @override
  Future<void> loadPage(int pageNumber) async {
    if (searchQuery.isEmpty) {
      searchResults = null;
      searchErrorMessage = null;
      notifyListeners();
      return;
    }

    final validationError = RegexValidationViewModel.validateNickname(
      searchQuery,
    );
    if (validationError != null) {
      searchResults = null;
      searchErrorMessage = validationError;
      notifyListeners();
      return;
    }

    isSearching = true;
    searchErrorMessage = null;
    notifyListeners();

    try {
      final request = UsersSearchRequestApiModel(
        nickname: searchQuery,
        pageNumber: pageNumber,
        pageSize: _searchPageSize,
      );

      searchResults = await _usersRepository.search(request);
      isSearching = false;
      notifyListeners();
    } on SessionExpiredException {
      searchErrorMessage = 'Session expired. Please login again.';
      isSearching = false;
      notifyListeners();
      onSessionExpired?.call();
    } on ForbiddenException {
      isSearching = false;
      notifyListeners();
      onForbidden?.call();
    } catch (e) {
      searchErrorMessage = e.toString();
      isSearching = false;
      notifyListeners();
    }
  }

  Future<void> init() async {
    userUuid = await TokenStorage.getCurrentUserUuid();
    userName = await TokenStorage.getCurrentUserName();
    notifyListeners();
  }

  Future<void> logout() async {
    final refreshToken = await TokenStorage.getRefreshToken();

    if (userUuid == null || refreshToken == null) return;

    isLoggingOut = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _ssoRepository.logout(
        SsoLogoutRequestApiModel(
          userUuid: userUuid!,
          userRefreshToken: refreshToken,
        ),
      );

      await TokenStorage.clearAuthToken();
      isLoggingOut = false;
      notifyListeners();

      onLogoutSuccess?.call();
    } catch (e) {
      errorMessage = 'Logout failed. Please try again.';
      isLoggingOut = false;
      notifyListeners();
    }
  }

  void navigateToLibrary(BuildContext context) {
    Navigator.of(context).pop();
    // TODO: Navigate to Library page
  }

  void navigateToSettings(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsPageScreen()));
  }

  void navigateToUserProfile(BuildContext context) {
    if (userUuid == null) return;

    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => UserProfilePageScreen(userUuid: userUuid!),
      ),
    );
  }

  void onSearchChanged(String query) {
    searchQuery = query;
    loadPage(1);
  }

  void resetSearchState() {
    searchResults = null;
    searchQuery = '';
    searchController.clear();
    searchErrorMessage = null;
  }

  @override
  void dispose() {
    searchController.dispose();
    onLogoutSuccess = null;
    onSessionExpired = null;
    onForbidden = null;
    super.dispose();
  }
}

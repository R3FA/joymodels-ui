import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/network_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/models/request_types/model_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_logout_request_api_model.dart';
import 'package:joymodels_mobile/data/model/users/request_types/user_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/users/response_types/users_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/model_repository.dart';
import 'package:joymodels_mobile/data/repositories/sso_repository.dart';
import 'package:joymodels_mobile/data/repositories/users_repository.dart';
import 'package:joymodels_mobile/ui/core/mixins/pagination_mixin.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';
import 'package:joymodels_mobile/ui/library_page/view_model/library_page_view_model.dart';
import 'package:joymodels_mobile/ui/library_page/widgets/library_page_screen.dart';
import 'package:joymodels_mobile/ui/settings_page/widgets/settings_page_screen.dart';
import 'package:joymodels_mobile/ui/user_profile_page/view_model/user_profile_page_view_model.dart';
import 'package:joymodels_mobile/ui/user_profile_page/widgets/user_profile_page_screen.dart';
import 'package:provider/provider.dart';

class MenuDrawerViewModel extends ChangeNotifier
    with PaginationMixin<UsersResponseApiModel> {
  final _ssoRepository = sl<SsoRepository>();
  final _usersRepository = sl<UsersRepository>();
  final _modelRepository = sl<ModelRepository>();

  bool isLoggingOut = false;
  bool isAdminOrRoot = false;
  String? userUuid;
  String? userName;
  String? errorMessage;

  bool isSearching = false;
  String? searchErrorMessage;
  PaginationResponseApiModel<UsersResponseApiModel>? searchResults;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  static const int _searchPageSize = 10;

  bool isHiddenModelsSearching = false;
  String? hiddenModelsErrorMessage;
  PaginationResponseApiModel<ModelResponseApiModel>? hiddenModelsResults;
  String hiddenModelsSearchQuery = '';
  final TextEditingController hiddenModelsSearchController =
      TextEditingController();
  int hiddenModelsCurrentPage = 1;

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

    final validationError = RegexValidationViewModel.validateText(searchQuery);
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
    } on NetworkException {
      searchErrorMessage = NetworkException().toString();
      isSearching = false;
      notifyListeners();
    } catch (e) {
      searchErrorMessage = e.toString();
      isSearching = false;
      notifyListeners();
    }
  }

  Future<void> init() async {
    userUuid = await TokenStorage.getCurrentUserUuid();
    userName = await TokenStorage.getCurrentUserName();
    isAdminOrRoot = await TokenStorage.isAdminOrRoot();
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
    } on SessionExpiredException {
      isLoggingOut = false;
      notifyListeners();
      onSessionExpired?.call();
    } on ForbiddenException {
      isLoggingOut = false;
      notifyListeners();
      onForbidden?.call();
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isLoggingOut = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Logout failed. Please try again.';
      isLoggingOut = false;
      notifyListeners();
    }
  }

  void navigateToLibrary(BuildContext context) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => LibraryPageViewModel(),
          child: const LibraryPageScreen(),
        ),
      ),
    );
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
        builder: (_) => ChangeNotifierProvider(
          create: (_) => UserProfilePageViewModel()..init(userUuid!),
          child: UserProfilePageScreen(userUuid: userUuid!),
        ),
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

  Future<void> searchHiddenModels(int pageNumber) async {
    final query = hiddenModelsSearchQuery;

    if (query.isNotEmpty) {
      final validationError = RegexValidationViewModel.validateText(query);
      if (validationError != null) {
        hiddenModelsResults = null;
        hiddenModelsErrorMessage = validationError;
        notifyListeners();
        return;
      }
    }

    isHiddenModelsSearching = true;
    hiddenModelsErrorMessage = null;
    notifyListeners();

    try {
      final request = ModelSearchRequestApiModel(
        modelName: query.isNotEmpty ? query : null,
        arePrivateUserModelsSearched: true,
        pageNumber: pageNumber,
        pageSize: _searchPageSize,
      );

      hiddenModelsResults = await _modelRepository.search(request);
      hiddenModelsCurrentPage = pageNumber;
      isHiddenModelsSearching = false;
      notifyListeners();
    } on SessionExpiredException {
      hiddenModelsErrorMessage = 'Session expired. Please login again.';
      isHiddenModelsSearching = false;
      notifyListeners();
      onSessionExpired?.call();
    } on ForbiddenException {
      isHiddenModelsSearching = false;
      notifyListeners();
      onForbidden?.call();
    } on NetworkException {
      hiddenModelsErrorMessage = NetworkException().toString();
      isHiddenModelsSearching = false;
      notifyListeners();
    } catch (e) {
      hiddenModelsErrorMessage = e.toString();
      isHiddenModelsSearching = false;
      notifyListeners();
    }
  }

  void onHiddenModelsSearchChanged(String query) {
    hiddenModelsSearchQuery = query;
    searchHiddenModels(1);
  }

  void resetHiddenModelsState() {
    hiddenModelsResults = null;
    hiddenModelsSearchQuery = '';
    hiddenModelsSearchController.clear();
    hiddenModelsErrorMessage = null;
    hiddenModelsCurrentPage = 1;
  }

  int get hiddenModelsTotalPages => hiddenModelsResults?.totalPages ?? 1;

  bool get hiddenModelsHasPreviousPage => hiddenModelsCurrentPage > 1;

  bool get hiddenModelsHasNextPage =>
      hiddenModelsCurrentPage < hiddenModelsTotalPages;

  void onHiddenModelsPreviousPage() {
    if (hiddenModelsHasPreviousPage) {
      searchHiddenModels(hiddenModelsCurrentPage - 1);
    }
  }

  void onHiddenModelsNextPage() {
    if (hiddenModelsHasNextPage) {
      searchHiddenModels(hiddenModelsCurrentPage + 1);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    hiddenModelsSearchController.dispose();
    onLogoutSuccess = null;
    onSessionExpired = null;
    onForbidden = null;
    super.dispose();
  }
}

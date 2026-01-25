import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/network_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/category/request_types/category_request_api_model.dart';
import 'package:joymodels_mobile/data/model/category/response_types/category_response_api_model.dart';
import 'package:joymodels_mobile/data/model/enums/jwt_claim_key_api_enum.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/model/users/request_types/user_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/users/response_types/users_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/category_repository.dart';
import 'package:joymodels_mobile/data/repositories/notification_repository.dart';
import 'package:joymodels_mobile/data/repositories/users_repository.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';
import 'package:joymodels_mobile/ui/model_search_page/widgets/model_search_page_screen.dart';
import 'package:joymodels_mobile/ui/user_profile_page/view_model/user_profile_page_view_model.dart';
import 'package:joymodels_mobile/ui/user_profile_page/widgets/user_profile_page_screen.dart';
import 'package:provider/provider.dart';

class HomePageScreenViewModel with ChangeNotifier {
  final usersRepository = sl<UsersRepository>();
  final categoryRepository = sl<CategoryRepository>();
  final notificationRepository = sl<NotificationRepository>();

  bool isLoading = false;
  int unreadNotificationCount = 0;
  bool isSearching = false;
  bool isLoggedUserDataLoading = false;
  bool isCategoriesLoading = false;
  bool isTopArtistsLoading = false;
  bool isTopArtistsPictureLoading = false;

  final searchController = TextEditingController();
  final topArtistsSearchController = TextEditingController();
  String? topArtistsSearchError;
  int _topArtistsModalPage = 1;
  String? _topArtistsModalSearchQuery;
  static const int _topArtistsModalPageSize = 10;

  int get topArtistsModalCurrentPage => topArtists?.pageNumber ?? 1;
  int get topArtistsModalTotalPages => topArtists?.totalPages ?? 1;
  bool get topArtistsModalHasPreviousPage =>
      topArtists?.hasPreviousPage ?? false;
  bool get topArtistsModalHasNextPage => topArtists?.hasNextPage ?? false;

  String loggedUsername = '';
  String? loggedUserUuid;
  Uint8List loggedUserAvatarUrl = Uint8List(0);

  PaginationResponseApiModel<CategoryResponseApiModel>? categories;

  PaginationResponseApiModel<UsersResponseApiModel>? topArtists;
  Map<String, Uint8List> topArtistsAvatars = {};

  // TODO: Implementirati kada bude spremno za recommendera
  PaginationResponseApiModel<ModelResponseApiModel>? recommendedModels;
  Map<String, Uint8List> recommendedModelsAvatars = {};

  String? selectedCategory;
  String? errorMessage;

  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;

  Future<void> init() async {
    isLoading = true;
    notifyListeners();
    try {
      await getLoggedUserDataFromToken();
      await getLoggedUserProfilePicture();
      await getCategories();
      await getTopArtists();
      await getTopArtistsProfilePicture();
      await fetchUnreadNotificationCount();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  void onSearchPressed() {
    isSearching = true;
    notifyListeners();
  }

  void onSearchCancelled() {
    isSearching = false;
    searchController.clear();
    notifyListeners();
  }

  void onSearchSubmitted(BuildContext context, String query) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ModelsSearchScreen(modelName: query)),
    );
  }

  void onCategoryTap(BuildContext context, CategoryResponseApiModel category) {
    if (selectedCategory == category.uuid) {
      selectedCategory = null;
      notifyListeners();
      return;
    }

    selectedCategory = category.uuid;
    notifyListeners();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ModelsSearchScreen(selectedCategory: category),
      ),
    );

    selectedCategory = null;
    notifyListeners();
  }

  void onViewAllCategoriesPressed(BuildContext context) {
    selectedCategory = 'View All';
    notifyListeners();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ModelsSearchScreen(selectedCategory: null),
      ),
    );

    selectedCategory = null;
    notifyListeners();
  }

  Future<void> getLoggedUserDataFromToken() async {
    final username = await TokenStorage.getClaimFromToken(
      JwtClaimKeyApiEnum.userName,
    );
    final userUuid = await TokenStorage.getClaimFromToken(
      JwtClaimKeyApiEnum.nameIdentifier,
    );

    if (username != null && userUuid != null) {
      loggedUsername = username;
      loggedUserUuid = userUuid;
      notifyListeners();
    } else {
      errorMessage = SessionExpiredException().toString();
      notifyListeners();
      onSessionExpired?.call();
    }
  }

  Future<bool> getLoggedUserProfilePicture() async {
    errorMessage = null;
    isLoggedUserDataLoading = true;
    notifyListeners();

    try {
      final usersAvatar = await usersRepository.getUserAvatar(
        (await TokenStorage.getClaimFromToken(
          JwtClaimKeyApiEnum.nameIdentifier,
        ))!,
      );

      isLoggedUserDataLoading = false;

      loggedUserAvatarUrl = usersAvatar.fileBytes;

      notifyListeners();
      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      notifyListeners();
      await Future.delayed(const Duration(seconds: 3));
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isLoggedUserDataLoading = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isLoggedUserDataLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isLoggedUserDataLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> getCategories() async {
    errorMessage = null;
    isCategoriesLoading = true;
    notifyListeners();

    try {
      final categoryRequest = CategorySearchRequestApiModel(
        categoryName: null,
        pageNumber: 1,
        pageSize: 8,
      );

      categories = await categoryRepository.search(categoryRequest);
      isCategoriesLoading = false;
      notifyListeners();

      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      isCategoriesLoading = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isCategoriesLoading = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isCategoriesLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isCategoriesLoading = false;
      notifyListeners();
      return false;
    }
  }

  IconData iconForCategory(String categoryName) {
    switch (categoryName) {
      case "Characters":
        return Icons.people_alt;
      case "Humans":
        return Icons.person;
      case "Robots & Mechanics":
        return Icons.smart_toy;
      case "Animals":
        return Icons.pets;
      case "Plants & Vegetation":
        return Icons.local_florist;
      case "Rocks & Minerals":
        return Icons.terrain;
      case "Terrain & Landscapes":
        return Icons.landscape;
      case "Buildings":
        return Icons.location_city;
      case "Interiors":
        return Icons.chair;
      case "Props":
        return Icons.toys;
      case "Industrial & Factory":
        return Icons.factory;
      case "Tools & Hardware":
        return Icons.handyman;
      case "Electronics & Gadgets":
        return Icons.devices;
      case "Clothing & Accessories":
        return Icons.checkroom;
      case "Jewelry":
        return Icons.emoji_objects;
      case "Sports & Fitness":
        return Icons.sports;
      case "Medical & Anatomy":
        return Icons.medical_services;
      case "Military":
        return Icons.military_tech;
      case "Sci‑Fi":
        return Icons.auto_awesome;
      case "Fantasy":
        return Icons.whatshot;
      case "Horror":
        return Icons.nightlight_round;
      case "Musical Instruments":
        return Icons.music_note;
      case "Office & Education":
        return Icons.school;
      case "Boats & Ships":
        return Icons.directions_boat;
      case "Aircraft & Drones":
        return Icons.flight;
      case "Spacecraft":
        return Icons.rocket;
      case "Trains & Rail":
        return Icons.train;
      case "Nature Elements":
        return Icons.nature;
      case "History":
        return Icons.menu_book;
      case "View All":
        return Icons.grid_view;
      default:
        return Icons.grid_view;
    }
  }

  Future<bool> getTopArtists({
    String? nickname,
    int pageNumber = 1,
    int pageSize = 5,
  }) async {
    errorMessage = null;
    isTopArtistsLoading = true;
    notifyListeners();

    try {
      final artistSearch = UsersSearchRequestApiModel(
        nickname: nickname,
        pageNumber: pageNumber,
        pageSize: pageSize,
      );

      topArtists = await usersRepository.searchTopArtists(artistSearch);
      isTopArtistsLoading = false;
      notifyListeners();
      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      isTopArtistsLoading = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isTopArtistsLoading = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isTopArtistsLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isTopArtistsLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> getTopArtistsProfilePicture() async {
    errorMessage = null;
    isTopArtistsPictureLoading = true;
    notifyListeners();

    try {
      for (int i = 0; i < (topArtists!.data.length); i++) {
        final artist = topArtists!.data[i];
        final avatar = await usersRepository.getUserAvatar(artist.uuid);
        topArtistsAvatars[artist.uuid] = avatar.fileBytes;
      }
      isTopArtistsPictureLoading = false;
      notifyListeners();
      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      isTopArtistsPictureLoading = false;
      notifyListeners();
      await Future.delayed(const Duration(seconds: 3));
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isTopArtistsPictureLoading = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isTopArtistsPictureLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isTopArtistsPictureLoading = false;
      notifyListeners();
      return false;
    }
  }

  void onOwnProfileTap(BuildContext context) {
    if (loggedUserUuid == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => UserProfilePageViewModel()..init(loggedUserUuid!),
          child: UserProfilePageScreen(userUuid: loggedUserUuid!),
        ),
      ),
    );
  }

  void onArtistTap(BuildContext context, UsersResponseApiModel? artist) {
    if (artist == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => UserProfilePageViewModel()..init(artist.uuid),
          child: UserProfilePageScreen(userUuid: artist.uuid),
        ),
      ),
    );
  }

  Future<void> searchTopArtistsModal(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isNotEmpty) {
      final validationError = RegexValidationViewModel.validateNickname(
        trimmedQuery,
      );
      if (validationError != null) {
        topArtistsSearchError = validationError;
        notifyListeners();
        return;
      }
    }

    topArtistsSearchError = null;
    _topArtistsModalPage = 1;
    _topArtistsModalSearchQuery = trimmedQuery.isEmpty ? null : trimmedQuery;
    notifyListeners();

    await getTopArtists(
      nickname: _topArtistsModalSearchQuery,
      pageNumber: _topArtistsModalPage,
      pageSize: _topArtistsModalPageSize,
    );
    await getTopArtistsProfilePicture();
  }

  Future<void> onTopArtistsModalNextPage() async {
    if (!topArtistsModalHasNextPage || isTopArtistsLoading) return;
    _topArtistsModalPage++;
    await getTopArtists(
      nickname: _topArtistsModalSearchQuery,
      pageNumber: _topArtistsModalPage,
      pageSize: _topArtistsModalPageSize,
    );
    await getTopArtistsProfilePicture();
  }

  Future<void> onTopArtistsModalPreviousPage() async {
    if (!topArtistsModalHasPreviousPage || isTopArtistsLoading) return;
    _topArtistsModalPage--;
    await getTopArtists(
      nickname: _topArtistsModalSearchQuery,
      pageNumber: _topArtistsModalPage,
      pageSize: _topArtistsModalPageSize,
    );
    await getTopArtistsProfilePicture();
  }

  Future<void> onTopArtistsModalClosed() async {
    topArtistsSearchController.clear();
    topArtistsSearchError = null;
    _topArtistsModalPage = 1;
    _topArtistsModalSearchQuery = null;
    await getTopArtists();
    await getTopArtistsProfilePicture();
  }

  Future<void> onViewAllArtistsPressed(BuildContext context) async {
    topArtistsSearchController.clear();
    topArtistsSearchError = null;
    _topArtistsModalPage = 1;
    _topArtistsModalSearchQuery = null;
    await getTopArtists(pageSize: _topArtistsModalPageSize);
    await getTopArtistsProfilePicture();
  }

  void onViewAllModelsPressed(BuildContext context) {
    // TODO: Implementirati kada bude spremno
  }

  Future<void> fetchUnreadNotificationCount() async {
    try {
      unreadNotificationCount = await notificationRepository.getUnreadCount();
      notifyListeners();
    } on SessionExpiredException {
      onSessionExpired?.call();
    } on ForbiddenException {
      onForbidden?.call();
    } on NetworkException {
      unreadNotificationCount = 0;
      notifyListeners();
    } catch (e) {
      unreadNotificationCount = 0;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    topArtistsSearchController.dispose();
    onSessionExpired = null;
    onForbidden = null;
    super.dispose();
  }
}

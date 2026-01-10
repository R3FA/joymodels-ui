import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/category/request_types/category_request_api_model.dart';
import 'package:joymodels_mobile/data/model/category/response_types/category_response_api_model.dart';
import 'package:joymodels_mobile/data/model/enums/jwt_claim_key_api_enum.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/model/users/request_types/user_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/users/response_types/users_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/category_repository.dart';
import 'package:joymodels_mobile/data/repositories/users_repository.dart';
import 'package:joymodels_mobile/ui/model_search_page/widgets/model_search_page_screen.dart';

class HomePageScreenViewModel with ChangeNotifier {
  final usersRepository = sl<UsersRepository>();
  final categoryRepository = sl<CategoryRepository>();

  bool isLoading = false;
  bool isSearching = false;
  bool isLoggedUserDataLoading = false;
  bool isCategoriesLoading = false;
  bool isTopArtistsLoading = false;
  bool isTopArtistsPictureLoading = false;

  final searchController = TextEditingController();

  String loggedUsername = '';
  Uint8List loggedUserAvatarUrl = Uint8List(0);

  PaginationResponseApiModel<CategoryResponseApiModel>? categories;

  PaginationResponseApiModel<UsersResponseApiModel>? topArtists;
  Map<String, Uint8List> topArtistsAvatars = {};

  String? selectedCategory;
  String? errorMessage;

  VoidCallback? onSessionExpired;

  Future<void> init() async {
    isLoading = true;
    notifyListeners();
    try {
      await getLoggedUserDataFromToken();
      await getLoggedUserProfilePicture();
      await getCategories();
      await getTopArtists();
      await getTopArtistsProfilePicture();

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

  void onSearchSubmitted(String query) {
    if (query.trim().isEmpty) return;

    // TODO: Navigacija na search rezultate
    // Navigator.of(context).push(
    //   MaterialPageRoute(builder: (_) => SearchResultsScreen(query: query)),
    // );
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
        builder: (_) => ModelsSearchScreen(categoryName: category.categoryName),
      ),
    );

    selectedCategory = null;
    notifyListeners();
  }

  void onViewAllCategoriesPressed(BuildContext context) {
    selectedCategory = 'View All';
    notifyListeners();

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ModelsSearchScreen(categoryName: null)),
    );

    selectedCategory = null;
    notifyListeners();
  }

  Future<void> getLoggedUserDataFromToken() async {
    final username = await TokenStorage.getClaimFromToken(
      JwtClaimKeyApiEnum.userName,
    );

    if (username != null) {
      loggedUsername = username;
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

  Future<bool> getTopArtists() async {
    errorMessage = null;
    isTopArtistsLoading = true;
    notifyListeners();

    try {
      final artistSearch = UsersSearchRequestApiModel(
        nickname: null,
        pageNumber: 1,
        pageSize: 5,
      );

      topArtists = await usersRepository.search(artistSearch);
      isTopArtistsLoading = false;
      notifyListeners();
      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      isTopArtistsLoading = false;
      notifyListeners();
      onSessionExpired?.call();
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
    } catch (e) {
      errorMessage = e.toString();
      isTopArtistsPictureLoading = false;
      notifyListeners();
      return false;
    }
  }

  void onArtistTap(BuildContext context, UsersResponseApiModel? artist) {
    if (artist == null) return;

    // TODO: Implementirati kada bude spremno
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder:  (_) => ArtistDetailScreen(artist: artist),
    //   ),
    // );
  }

  void onViewAllArtistsPressed(BuildContext context) {
    // TODO: Implementirati kada bude spremno
    // Navigator.of(
    //   context,
    // ).push(MaterialPageRoute(builder: (_) => const TopArtistScreen()));
  }

  void onViewAllModelsPressed(BuildContext context) {
    // TODO: Implementirati kada bude spremno
    // Navigator.of(context).push(
    //   MaterialPageRoute(builder: (_) => const TopModelsScreen()),
    // );
  }

  @override
  void dispose() {
    searchController.dispose();
    onSessionExpired = null;
    super.dispose();
  }
}

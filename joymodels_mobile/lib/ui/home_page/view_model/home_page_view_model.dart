import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/category/request_types/category_request_api_model.dart';
import 'package:joymodels_mobile/data/model/category/response_types/category_response_api_model.dart';
import 'package:joymodels_mobile/data/model/enums/jwt_claim_key_api_enum.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/category_repository.dart';
import 'package:joymodels_mobile/data/repositories/users_repository.dart';

class ArtistModel {
  final String name;
  final String imageUrl;
  final int count;

  ArtistModel({
    required this.name,
    required this.imageUrl,
    required this.count,
  });
}

class TopModel {
  final String name;
  final String imageUrl;
  final String price;

  TopModel({required this.name, required this.imageUrl, required this.price});
}

class HomePageScreenViewModel with ChangeNotifier {
  final usersRepository = sl<UsersRepository>();
  final categoryRepository = sl<CategoryRepository>();

  late String loggedUsername = '';
  late Uint8List loggedUserAvatarUrl = Uint8List(0);
  PaginationResponseApiModel<CategoryResponseApiModel>? categories;

  int selectedNavBarItem = 0;
  String? selectedCategory;

  String? errorMessage;
  VoidCallback? onSessionExpired;

  bool isLoggedUserDataLoading = false;
  bool isCategoriesLoading = false;

  Future<void> init() async {
    await getLoggedUserDataFromToken();
    await getLoggedUserProfilePicture();
    await getCategories();
  }

  void onNavigationBarItemTapped(int index) {
    selectedNavBarItem = index;
    notifyListeners();
  }

  void onCategoryTap(CategoryResponseApiModel cat) {
    if (selectedCategory == cat.uuid) {
      selectedCategory = null;
      notifyListeners();
      return;
    }

    selectedCategory = cat.uuid;
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

  List<ArtistModel> topArtists = [
    ArtistModel(
      name: "Sam Lake",
      imageUrl: "https://i.imgur.com/9wN3OQp.png",
      count: 437,
    ),
    ArtistModel(
      name: "Dan Houser",
      imageUrl: "https://i.imgur.com/gsRGk8q.png",
      count: 631,
    ),
    ArtistModel(
      name: "Kojima",
      imageUrl: "https://i.imgur.com/B4Z6ipM.png",
      count: 211,
    ),
  ];

  List<TopModel> topRatedModels = [
    TopModel(
      name: "Max Payne – 3D Model",
      imageUrl: "https://i.imgur.com/PIIogMz.png",
      price: "\$19,99",
    ),
    TopModel(
      name: "Alan Wake – 3D Model",
      imageUrl: "https://i.imgur.com/F4onsfb.png",
      price: "",
    ),
  ];

  @override
  void dispose() {
    onSessionExpired = null;
    errorMessage = null;
    super.dispose();
  }
}

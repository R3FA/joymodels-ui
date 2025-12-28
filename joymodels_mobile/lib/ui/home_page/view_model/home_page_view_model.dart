import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/model/enums/jwt_claim_key_api_enum.dart';
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

  late String loggedUsername = '';
  late Uint8List loggedUserAvatarUrl = Uint8List(0);

  int selectedIndex = 0;

  String? errorMessage;
  bool? isLoggedUserDataLoading = false;

  Future<void> init() async {
    await getLoggedUserDataFromToken();
    await getLoggedUserProfilePicture();
  }

  void onNavigationBarItemTapped(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  Future<void> getLoggedUserDataFromToken() async {
    loggedUsername = (await TokenStorage.getClaimFromToken(
      JwtClaimKeyApiEnum.userName,
    ))!;
    notifyListeners();
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
    } catch (e) {
      errorMessage = e.toString();
      isLoggedUserDataLoading = false;
      notifyListeners();
      return false;
    }
  }

  List<Map<String, dynamic>> categories = [
    {"icon": Icons.account_circle, "label": "Creatures"},
    {"icon": Icons.directions_car, "label": "Vehicles"},
    {"icon": Icons.account_balance, "label": "History"},
    {"icon": Icons.set_meal, "label": "Food & Drinks"},
    {"icon": Icons.chair, "label": "Furniture"},
    {"icon": Icons.science, "label": "Science"},
    {"icon": Icons.grid_view, "label": "More"},
  ];

  List<ArtistModel> topArtists = [
    ArtistModel(
      name: "Sam Lake",
      imageUrl: "https://i.imgur.com/9wN3OQp.png", // zamijeni svojim slikama
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
}

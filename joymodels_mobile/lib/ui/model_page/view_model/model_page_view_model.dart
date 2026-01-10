import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/model/core/response_types/picture_response_api_model.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/model_repository.dart';

class ModelPageViewModel extends ChangeNotifier {
  final modelRepository = sl<ModelRepository>();

  bool isLoading = false;
  bool areModelImagesLoading = false;

  String? errorMessage;

  ModelResponseApiModel? loadedModel;
  List<PictureResponse?> modelPictures = List.empty(growable: true);

  int galleryIndex = 0;
  late final PageController galleryController = PageController(initialPage: 0);

  VoidCallback? onSessionExpired;

  ModelPageViewModel() {
    galleryController.addListener(() {});
  }

  Future<void> init({required ModelResponseApiModel? loadedModel}) async {
    clear();
    isLoading = true;
    notifyListeners();

    try {
      this.loadedModel = loadedModel;
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  void nextGallery() {
    if (galleryIndex < modelPictures.length - 1) {
      galleryIndex++;
      galleryController.jumpToPage(galleryIndex);
      notifyListeners();
    }
  }

  void previousGallery() {
    if (galleryIndex > 0) {
      galleryIndex--;
      galleryController.jumpToPage(galleryIndex);
      notifyListeners();
    }
  }

  void onGalleryPageChanged(int index) {
    galleryIndex = index;
    notifyListeners();
  }

  void onCategory() {
    // TODO: Implement category action
  }

  // Reviews
  void onViewAllReviews() {
    // TODO: Implement view all reviews action
  }

  // Buy
  void onAddToCart() {
    // TODO: Implement add to cart action
  }

  // FAQ
  String get faqUserAvatar => "https://randomuser.me/api/portraits/men/75.jpg";
  String get faqUsername => "Heisenberg";
  String get faqQuestion => "Is this model compatible with blender?";
  void onViewAllFAQ() {}

  // Misc
  void onSearchPressed() {}

  void clear() {
    isLoading = false;
    areModelImagesLoading = false;
    errorMessage = null;
    loadedModel = null;
    modelPictures.clear();
    galleryIndex = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    galleryController.dispose();
    super.dispose();
  }
}

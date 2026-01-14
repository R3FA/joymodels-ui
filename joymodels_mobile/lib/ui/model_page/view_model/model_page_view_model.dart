import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/model_reviews/response_types/model_calculated_reviews_response_api_model.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/model_repository.dart';
import 'package:joymodels_mobile/data/repositories/model_reviews_repository.dart';

class ModelPageViewModel extends ChangeNotifier {
  final modelRepository = sl<ModelRepository>();
  final modelReviewsRepository = sl<ModelReviewsRepository>();

  bool isLoading = false;
  bool areModelImagesLoading = false;
  bool areReviewsLoading = false;

  String? errorMessage;

  ModelResponseApiModel? loadedModel;
  ModelCalculatedReviewsResponseApiModel? calculatedReviews;

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
      await getModelReviews(loadedModel!);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> getModelReviews(ModelResponseApiModel model) async {
    errorMessage = null;
    areReviewsLoading = true;
    notifyListeners();

    try {
      calculatedReviews = await modelReviewsRepository.calculateReviews(
        model.uuid,
      );
      areReviewsLoading = false;
      notifyListeners();

      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      areReviewsLoading = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      areReviewsLoading = false;
      notifyListeners();
      return false;
    }
  }

  Color getReviewColor(String reviewType, BuildContext context) {
    switch (reviewType) {
      case 'Positive':
        return Colors.blue;
      case 'Negative':
        return Colors.red;
      case 'Mixed':
        return Colors.brown;
      default:
        return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    }
  }

  void nextGallery() {
    if (galleryIndex < (loadedModel?.modelPictures.length ?? 0) - 1) {
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
    galleryIndex = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    galleryController.dispose();
    super.dispose();
  }
}

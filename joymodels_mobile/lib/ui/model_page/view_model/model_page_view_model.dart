import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/model_reviews/response_types/model_calculated_reviews_response_api_model.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/model_repository.dart';
import 'package:joymodels_mobile/data/repositories/model_reviews_repository.dart';
import 'package:joymodels_mobile/ui/home_page/widgets/home_page_screen.dart';

class ModelPageViewModel extends ChangeNotifier {
  final modelRepository = sl<ModelRepository>();
  final modelReviewsRepository = sl<ModelReviewsRepository>();

  bool isLoading = false;
  bool areModelImagesLoading = false;
  bool areReviewsLoading = false;
  bool isModelLiked = false;
  bool isModelBeingDeleted = false;

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
      await isModelLikedByUser(loadedModel);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isModelLikedByUser(ModelResponseApiModel model) async {
    errorMessage = null;
    notifyListeners();

    try {
      isModelLiked = await modelRepository.isModelLiked(model.uuid);
      notifyListeners();
      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
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

  Future<bool> onLikeModel() async {
    isModelLiked = !isModelLiked;
    errorMessage = null;
    notifyListeners();

    if (isModelLiked) {
      try {
        await modelRepository.modelLike(loadedModel!.uuid);
        notifyListeners();
        return true;
      } on SessionExpiredException {
        errorMessage = SessionExpiredException().toString();
        notifyListeners();
        onSessionExpired?.call();
        return false;
      } catch (e) {
        errorMessage = e.toString();
        notifyListeners();
        return false;
      }
    } else {
      try {
        await modelRepository.modelUnlike(loadedModel!.uuid);
        notifyListeners();
        return true;
      } on SessionExpiredException {
        errorMessage = SessionExpiredException().toString();
        notifyListeners();
        onSessionExpired?.call();
        return false;
      } catch (e) {
        errorMessage = e.toString();
        notifyListeners();
        return false;
      }
    }
  }

  void onReportModel() {
    // TODO: Dodaj logiku za prijavu modela (prikaz modala, API call ...)
  }

  void onEditModel() {
    // TODO: Dodaj logiku za izmjenu modela (navigacija na edit screen itd.)
  }

  Future<bool> onDeleteModel(BuildContext context) async {
    errorMessage = null;
    isModelBeingDeleted = true;
    notifyListeners();

    try {
      await modelRepository.delete(loadedModel!.uuid);
      isModelBeingDeleted = false;
      if (context.mounted) {
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacement(MaterialPageRoute(builder: (_) => HomePageScreen()));
      }
      notifyListeners();
      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      isModelBeingDeleted = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isModelBeingDeleted = false;
      notifyListeners();
      return false;
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

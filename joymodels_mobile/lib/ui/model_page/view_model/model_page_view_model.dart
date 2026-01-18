import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/model_reviews/response_types/model_calculated_reviews_response_api_model.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/data/model/shopping_cart/request_types/shopping_cart_item_add_request_api_model.dart';
import 'package:joymodels_mobile/data/repositories/model_repository.dart';
import 'package:joymodels_mobile/data/repositories/model_reviews_repository.dart';
import 'package:joymodels_mobile/data/repositories/shopping_cart_repository.dart';
import 'package:joymodels_mobile/ui/home_page/widgets/home_page_screen.dart';
import 'package:joymodels_mobile/ui/model_edit_page/view_model/model_edit_page_view_model.dart';
import 'package:joymodels_mobile/ui/model_edit_page/widgets/model_edit_page_screen.dart';
import 'package:joymodels_mobile/ui/model_reviews_page/view_model/model_reviews_page_view_model.dart';
import 'package:joymodels_mobile/ui/model_reviews_page/widgets/model_reviews_page_screen.dart';
import 'package:provider/provider.dart';

class ModelPageViewModel extends ChangeNotifier {
  final modelRepository = sl<ModelRepository>();
  final modelReviewsRepository = sl<ModelReviewsRepository>();
  final shoppingCartRepository = sl<ShoppingCartRepository>();

  bool isLoading = false;
  bool areReviewsLoading = false;
  bool isModelLiked = false;
  bool isModelBeingDeleted = false;
  bool isAddingToCart = false;
  bool isInCart = false;

  String? errorMessage;
  String? cartItemUuid;

  ModelResponseApiModel? loadedModel;
  ModelCalculatedReviewsResponseApiModel? calculatedReviews;

  int galleryIndex = 0;
  late final PageController galleryController = PageController(initialPage: 0);

  VoidCallback? onSessionExpired;

  Future<void> init({required ModelResponseApiModel? loadedModel}) async {
    clear();
    isLoading = true;
    notifyListeners();

    try {
      this.loadedModel = loadedModel;
      await getModelReviews(loadedModel!);
      await isModelLikedByUser(loadedModel);
      await checkIfModelInCart(loadedModel);
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> checkIfModelInCart(ModelResponseApiModel model) async {
    try {
      final cartItem = await shoppingCartRepository.getByUuid(model.uuid);
      isInCart = cartItem != null;
      cartItemUuid = cartItem?.uuid;
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
        return Colors.brown[300]!;
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

  Future<bool> onEditModel(BuildContext context) async {
    final result = await Navigator.push<ModelResponseApiModel>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ModelEditPageViewModel(),
          child: ModelEditPageScreen(model: loadedModel!),
        ),
      ),
    );

    if (result != null) {
      loadedModel = result;
      galleryIndex = 0;
      if (galleryController.hasClients) {
        galleryController.jumpToPage(0);
      }
      notifyListeners();
    }

    return result != null;
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

  void onViewAllReviews(BuildContext context) {
    if (loadedModel == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => ModelReviewsPageViewModel(),
          child: ModelReviewsPageScreen(modelUuid: loadedModel!.uuid),
        ),
      ),
    );
  }

  Future<bool> onToggleCart(BuildContext context) async {
    if (loadedModel == null) return false;

    if (isInCart) {
      return await onRemoveFromCart(context);
    } else {
      return await onAddToCart(context);
    }
  }

  Future<bool> onAddToCart(BuildContext context) async {
    if (loadedModel == null) return false;

    errorMessage = null;
    isAddingToCart = true;
    notifyListeners();

    try {
      final request = ShoppingCartItemAddRequestApiModel(
        modelUuid: loadedModel!.uuid,
      );
      final result = await shoppingCartRepository.create(request);
      isAddingToCart = false;

      if (result != null) {
        isInCart = true;
        cartItemUuid = result.uuid;
        notifyListeners();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${loadedModel!.name} added to cart'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return true;
      } else {
        await checkIfModelInCart(loadedModel!);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${loadedModel!.name} ${isInCart ? "already in" : "could not be added to"} cart',
              ),
              backgroundColor: isInCart ? Colors.orange : Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return isInCart;
      }
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      isAddingToCart = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isAddingToCart = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add to cart: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      return false;
    }
  }

  Future<bool> onRemoveFromCart(BuildContext context) async {
    if (loadedModel == null) return false;

    errorMessage = null;
    isAddingToCart = true;
    notifyListeners();

    try {
      await shoppingCartRepository.delete(loadedModel!.uuid);
      isAddingToCart = false;
      isInCart = false;
      cartItemUuid = null;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loadedModel!.name} removed from cart'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      isAddingToCart = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isAddingToCart = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove from cart: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      return false;
    }
  }

  String get faqUserAvatar => "https://randomuser.me/api/portraits/men/75.jpg";
  String get faqUsername => "Heisenberg";
  String get faqQuestion => "Is this model compatible with blender?";
  void onViewAllFAQ() {}

  void clear() {
    isLoading = false;
    errorMessage = null;
    loadedModel = null;
    galleryIndex = 0;
    isInCart = false;
    cartItemUuid = null;
    notifyListeners();
  }

  @override
  void dispose() {
    galleryController.dispose();
    onSessionExpired = null;
    super.dispose();
  }
}

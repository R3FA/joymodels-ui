import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/network_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/enums/model_review_enum.dart';
import 'package:joymodels_mobile/data/model/model_review_type/request_types/model_review_type_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_review_type/response_types/model_review_type_response_api_model.dart';
import 'package:joymodels_mobile/data/model/model_reviews/request_types/model_review_patch_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_reviews/request_types/model_review_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_reviews/response_types/model_review_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/model_review_type_repository.dart';
import 'package:joymodels_mobile/data/repositories/model_reviews_repository.dart';
import 'package:joymodels_mobile/ui/core/mixins/pagination_mixin.dart';

class ModelReviewsPageViewModel extends ChangeNotifier
    with PaginationMixin<ModelReviewResponseApiModel> {
  final modelReviewsRepository = sl<ModelReviewsRepository>();
  final modelReviewTypeRepository = sl<ModelReviewTypeRepository>();

  bool isLoading = false;
  bool isDeleting = false;
  bool isEditing = false;
  bool isLoadingReviewTypes = false;
  String? errorMessage;
  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;

  String? currentUserUuid;
  late String modelUuid;
  ModelReviewEnum selectedReviewType = ModelReviewEnum.all;
  List<ModelReviewTypeResponseApiModel> reviewTypes = [];

  PaginationResponseApiModel<ModelReviewResponseApiModel>? reviewsPagination;
  List<ModelReviewResponseApiModel> get reviews =>
      reviewsPagination?.data ?? [];

  @override
  PaginationResponseApiModel<ModelReviewResponseApiModel>? get paginationData =>
      reviewsPagination;

  @override
  bool get isLoadingPage => isLoading;

  @override
  Future<void> loadPage(int pageNumber) async {
    await loadReviews(pageNumber: pageNumber);
  }

  Future<void> init(String modelUuid) async {
    this.modelUuid = modelUuid;
    currentUserUuid = await TokenStorage.getCurrentUserUuid();
    await loadReviews();
  }

  bool isOwnReview(ModelReviewResponseApiModel review) {
    return currentUserUuid != null &&
        review.usersResponse.uuid == currentUserUuid;
  }

  Future<bool> loadReviews({int? pageNumber}) async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      final request = ModelReviewSearchRequestApiModel(
        modelUuid: modelUuid,
        modelReviewType: selectedReviewType,
        pageNumber: pageNumber ?? currentPage,
        pageSize: 10,
      );

      reviewsPagination = await modelReviewsRepository.search(request);
      isLoading = false;
      notifyListeners();

      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      isLoading = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isLoading = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> onFilterChanged(ModelReviewEnum reviewType) async {
    if (selectedReviewType == reviewType) return;

    selectedReviewType = reviewType;
    await loadReviews(pageNumber: 1);
  }

  Color getReviewTypeColor(BuildContext context, String reviewTypeName) {
    switch (reviewTypeName.toLowerCase()) {
      case 'positive':
        return Colors.blue;
      case 'negative':
        return Colors.red;
      default:
        return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black;
    }
  }

  Future<bool> loadReviewTypes() async {
    if (reviewTypes.isNotEmpty) return true;

    isLoadingReviewTypes = true;
    notifyListeners();

    try {
      final request = ModelReviewTypeSearchRequestApiModel(
        pageNumber: 1,
        pageSize: 50,
      );
      final result = await modelReviewTypeRepository.search(request);
      reviewTypes = result.data;
      isLoadingReviewTypes = false;
      notifyListeners();
      return true;
    } on SessionExpiredException {
      isLoadingReviewTypes = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isLoadingReviewTypes = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isLoadingReviewTypes = false;
      notifyListeners();
      return false;
    } catch (e) {
      isLoadingReviewTypes = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReview(
    BuildContext context,
    ModelReviewResponseApiModel review,
  ) async {
    isDeleting = true;
    notifyListeners();

    try {
      await modelReviewsRepository.delete(review.uuid);
      await loadReviews(pageNumber: currentPage);
      isDeleting = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return true;
    } on SessionExpiredException {
      isDeleting = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isDeleting = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isDeleting = false;
      notifyListeners();
      return false;
    } catch (e) {
      isDeleting = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete review: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return false;
    }
  }

  Future<bool> editReview(
    BuildContext context,
    String reviewUuid,
    String? newReviewTypeUuid,
    String? newReviewText,
  ) async {
    isEditing = true;
    notifyListeners();

    try {
      final request = ModelReviewPatchRequestApiModel(
        modelReviewUuid: reviewUuid,
        modelReviewTypeUuid: newReviewTypeUuid,
        modelReviewText: newReviewText,
      );
      await modelReviewsRepository.patch(request);
      await loadReviews(pageNumber: currentPage);
      isEditing = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review updated successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return true;
    } on SessionExpiredException {
      isEditing = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isEditing = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isEditing = false;
      notifyListeners();
      return false;
    } catch (e) {
      isEditing = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update review: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return false;
    }
  }

  @override
  void dispose() {
    onSessionExpired = null;
    onForbidden = null;
    super.dispose();
  }
}

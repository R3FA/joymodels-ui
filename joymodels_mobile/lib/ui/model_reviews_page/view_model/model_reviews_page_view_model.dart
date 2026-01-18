import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/enums/model_review_enum.dart';
import 'package:joymodels_mobile/data/model/model_reviews/request_types/model_review_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_reviews/response_types/model_review_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/model_reviews_repository.dart';

class ModelReviewsPageViewModel extends ChangeNotifier {
  final modelReviewsRepository = sl<ModelReviewsRepository>();

  bool isLoading = false;
  String? errorMessage;
  VoidCallback? onSessionExpired;

  late String modelUuid;
  ModelReviewEnum selectedReviewType = ModelReviewEnum.all;

  PaginationResponseApiModel<ModelReviewResponseApiModel>? reviewsPagination;
  List<ModelReviewResponseApiModel> get reviews =>
      reviewsPagination?.data ?? [];

  int get currentPage => reviewsPagination?.pageNumber ?? 1;
  int get totalPages => reviewsPagination?.totalPages ?? 1;
  bool get hasPreviousPage => reviewsPagination?.hasPreviousPage ?? false;
  bool get hasNextPage => reviewsPagination?.hasNextPage ?? false;

  Future<void> init(String modelUuid) async {
    this.modelUuid = modelUuid;
    await loadReviews();
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
        pageSize: 1,
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

  Future<void> onNextPage() async {
    if (hasNextPage && !isLoading) {
      await loadReviews(pageNumber: currentPage + 1);
    }
  }

  Future<void> onPreviousPage() async {
    if (hasPreviousPage && !isLoading) {
      await loadReviews(pageNumber: currentPage - 1);
    }
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

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    onSessionExpired = null;
    super.dispose();
  }
}

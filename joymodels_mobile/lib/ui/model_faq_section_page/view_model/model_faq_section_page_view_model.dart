import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/network_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/request_types/model_faq_section_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_faq_section/response_types/model_faq_section_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/model_faq_section_repository.dart';
import 'package:joymodels_mobile/ui/core/mixins/pagination_mixin.dart';

class ModelFaqSectionPageViewModel extends ChangeNotifier
    with PaginationMixin<ModelFaqSectionResponseApiModel> {
  final modelFaqSectionRepository = sl<ModelFaqSectionRepository>();

  bool isLoading = false;
  String? errorMessage;
  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;

  late String modelUuid;
  String? modelName;
  bool isMyFaqSectionFiltered = false;

  PaginationResponseApiModel<ModelFaqSectionResponseApiModel>? faqPagination;
  List<ModelFaqSectionResponseApiModel> get faqList =>
      faqPagination?.data ?? [];

  @override
  PaginationResponseApiModel<ModelFaqSectionResponseApiModel>?
  get paginationData => faqPagination;

  @override
  bool get isLoadingPage => isLoading;

  @override
  Future<void> loadPage(int pageNumber) async {
    await loadFAQ(pageNumber: pageNumber);
  }

  Future<void> init(String modelUuid, {String? modelName}) async {
    this.modelUuid = modelUuid;
    this.modelName = modelName;
    await loadFAQ();
  }

  Future<void> onAllFilterSelected() async {
    if (!isMyFaqSectionFiltered) return;

    isMyFaqSectionFiltered = false;
    await loadFAQ(pageNumber: 1);
  }

  Future<void> onMyFaqFilterSelected() async {
    if (isMyFaqSectionFiltered) return;

    isMyFaqSectionFiltered = true;
    await loadFAQ(pageNumber: 1);
  }

  Future<bool> loadFAQ({int? pageNumber}) async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      final request = ModelFaqSectionSearchRequestApiModel(
        modelUuid: modelUuid,
        isMyFaqSectionFiltered: isMyFaqSectionFiltered,
        pageNumber: pageNumber ?? currentPage,
        pageSize: 10,
      );

      faqPagination = await modelFaqSectionRepository.search(request);
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

  void updateFaqInList(ModelFaqSectionResponseApiModel updatedFaq) {
    if (faqPagination == null) return;

    final index = faqPagination!.data.indexWhere(
      (f) => f.uuid == updatedFaq.uuid,
    );
    if (index != -1) {
      faqPagination!.data[index] = updatedFaq;
      notifyListeners();
    }
  }

  void removeFaqFromList(String faqUuid) {
    if (faqPagination == null) return;

    faqPagination!.data.removeWhere((f) => f.uuid == faqUuid);
    notifyListeners();
  }

  @override
  void dispose() {
    onSessionExpired = null;
    onForbidden = null;
    super.dispose();
  }
}

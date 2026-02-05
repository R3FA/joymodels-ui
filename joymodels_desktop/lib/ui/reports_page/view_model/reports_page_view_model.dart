import 'package:flutter/material.dart';
import 'package:joymodels_desktop/core/di/di.dart';
import 'package:joymodels_desktop/data/core/exceptions/api_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/network_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_desktop/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_desktop/data/model/report/request_types/report_patch_status_request_api_model.dart';
import 'package:joymodels_desktop/data/model/report/request_types/report_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/report/response_types/report_response_api_model.dart';
import 'package:joymodels_desktop/data/model/enums/reported_entity_type_api_enum.dart';
import 'package:joymodels_desktop/data/model/model_faq_section/request_types/model_faq_section_delete_request_api_model.dart';
import 'package:joymodels_desktop/data/repositories/community_post_question_section_repository.dart';
import 'package:joymodels_desktop/data/repositories/community_post_repository.dart';
import 'package:joymodels_desktop/data/repositories/model_faq_section_repository.dart';
import 'package:joymodels_desktop/data/repositories/model_reviews_repository.dart';
import 'package:joymodels_desktop/data/repositories/report_repository.dart';
import 'package:joymodels_desktop/data/repositories/users_repository.dart';
import 'package:joymodels_desktop/ui/core/mixins/pagination_mixin.dart';

class ReportsPageViewModel extends ChangeNotifier
    with PaginationMixin<ReportResponseApiModel> {
  final _reportRepository = sl<ReportRepository>();
  final _usersRepository = sl<UsersRepository>();
  final _communityPostRepository = sl<CommunityPostRepository>();
  final _communityPostQuestionSectionRepository =
      sl<CommunityPostQuestionSectionRepository>();
  final _modelReviewsRepository = sl<ModelReviewsRepository>();
  final _modelFaqSectionRepository = sl<ModelFaqSectionRepository>();

  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;
  VoidCallback? onNetworkError;

  bool _isInitialized = false;
  bool _isDisposed = false;
  bool isLoading = false;
  String? errorMessage;

  PaginationResponseApiModel<ReportResponseApiModel>? pagination;

  String? filterStatus;
  String? filterEntityType;
  String? filterReason;

  static const int _pageSize = 10;

  @override
  PaginationResponseApiModel<ReportResponseApiModel>? get paginationData =>
      pagination;

  @override
  bool get isLoadingPage => isLoading;

  @override
  Future<void> loadPage(int pageNumber) => searchReports(page: pageNumber);

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await searchReports();
  }

  void clearErrorMessage() {
    errorMessage = null;
    notifyListeners();
  }

  void setFilterStatus(String? status) {
    filterStatus = status;
    notifyListeners();
  }

  void setFilterEntityType(String? entityType) {
    filterEntityType = entityType;
    notifyListeners();
  }

  void setFilterReason(String? reason) {
    filterReason = reason;
    notifyListeners();
  }

  Future<void> searchReports({int page = 1}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final request = ReportSearchRequestApiModel(
        status: filterStatus,
        reportedEntityType: filterEntityType,
        reason: filterReason,
        pageNumber: page,
        pageSize: _pageSize,
        orderBy: 'CreatedAt:desc',
      );

      pagination = await _reportRepository.search(request);
      isLoading = false;
      notifyListeners();
    } on SessionExpiredException {
      isLoading = false;
      notifyListeners();
      onSessionExpired?.call();
    } on ForbiddenException {
      isLoading = false;
      notifyListeners();
      onForbidden?.call();
    } on NetworkException {
      isLoading = false;
      notifyListeners();
      onNetworkError?.call();
    } on ApiException catch (e) {
      isLoading = false;
      errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> updateReportStatus(String reportUuid, String status) async {
    try {
      final request = ReportPatchStatusRequestApiModel(
        reportUuid: reportUuid,
        status: status,
      );
      await _reportRepository.patchStatus(request);
      await reloadCurrentPage();
    } on SessionExpiredException {
      onSessionExpired?.call();
    } on ForbiddenException {
      onForbidden?.call();
    } on NetworkException {
      onNetworkError?.call();
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
    }
  }

  Future<void> deleteReportedContent(
    String entityType,
    String entityUuid,
  ) async {
    try {
      final parsedType = ReportedEntityTypeApiEnum.values.where(
        (e) => e.name == entityType,
      );
      if (parsedType.isEmpty) {
        errorMessage = 'Unknown entity type: $entityType';
        notifyListeners();
        return;
      }
      switch (parsedType.first) {
        case ReportedEntityTypeApiEnum.User:
          await _usersRepository.delete(entityUuid);
        case ReportedEntityTypeApiEnum.CommunityPost:
          await _communityPostRepository.delete(entityUuid);
        case ReportedEntityTypeApiEnum.CommunityPostComment:
          await _communityPostQuestionSectionRepository.delete(entityUuid);
        case ReportedEntityTypeApiEnum.ModelReview:
          await _modelReviewsRepository.delete(entityUuid);
        case ReportedEntityTypeApiEnum.ModelFaqQuestion:
          await _modelFaqSectionRepository.delete(
            ModelFaqSectionDeleteRequestApiModel(
              modelFaqSectionUuid: entityUuid,
            ),
          );
      }
      await reloadCurrentPage();
    } on SessionExpiredException {
      onSessionExpired?.call();
    } on ForbiddenException {
      onForbidden?.call();
    } on NetworkException {
      onNetworkError?.call();
    } on ApiException catch (e) {
      errorMessage = e.message;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    onSessionExpired = null;
    onForbidden = null;
    onNetworkError = null;
    super.dispose();
  }

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }
}

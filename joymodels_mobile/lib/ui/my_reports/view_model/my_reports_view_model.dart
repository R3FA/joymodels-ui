import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/network_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/model/report/request_types/report_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/report/response_types/report_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/report_repository.dart';
import 'package:joymodels_mobile/ui/core/mixins/pagination_mixin.dart';

class MyReportsViewModel extends ChangeNotifier
    with PaginationMixin<ReportResponseApiModel> {
  final _reportRepository = sl<ReportRepository>();

  bool isLoading = false;
  bool isDeleting = false;
  String? errorMessage;
  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;

  PaginationResponseApiModel<ReportResponseApiModel>? _reportsPagination;
  List<ReportResponseApiModel> get reports => _reportsPagination?.data ?? [];

  @override
  PaginationResponseApiModel<ReportResponseApiModel>? get paginationData =>
      _reportsPagination;

  @override
  bool get isLoadingPage => isLoading;

  @override
  Future<void> loadPage(int pageNumber) async {
    await loadReports(pageNumber: pageNumber);
  }

  Future<void> init() async {
    await loadReports();
  }

  Future<bool> loadReports({int? pageNumber}) async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      final request = ReportSearchRequestApiModel(
        pageNumber: pageNumber ?? currentPage,
        pageSize: 10,
        orderBy: 'CreatedAt:desc',
      );

      _reportsPagination = await _reportRepository.myReports(request);
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
      errorMessage = 'Failed to load reports';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteReport(BuildContext context, String reportUuid) async {
    isDeleting = true;
    notifyListeners();

    try {
      await _reportRepository.delete(reportUuid);
      await loadReports(pageNumber: currentPage);
      isDeleting = false;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report deleted'),
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
          const SnackBar(
            content: Text('Failed to delete report'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
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

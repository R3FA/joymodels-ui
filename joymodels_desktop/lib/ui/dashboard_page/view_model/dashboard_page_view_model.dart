import 'package:flutter/material.dart';
import 'package:joymodels_desktop/core/di/di.dart';
import 'package:joymodels_desktop/data/core/exceptions/api_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/network_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_desktop/data/model/category/request_types/category_request_api_model.dart';
import 'package:joymodels_desktop/data/model/report/request_types/report_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/sso/request_types/sso_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/users/request_types/user_search_request_api_model.dart';
import 'package:joymodels_desktop/data/repositories/category_repository.dart';
import 'package:joymodels_desktop/data/repositories/report_repository.dart';
import 'package:joymodels_desktop/data/repositories/sso_repository.dart';
import 'package:joymodels_desktop/data/repositories/users_repository.dart';

class DashboardPageViewModel with ChangeNotifier {
  final _usersRepository = sl<UsersRepository>();
  final _ssoRepository = sl<SsoRepository>();
  final _categoryRepository = sl<CategoryRepository>();
  final _reportRepository = sl<ReportRepository>();

  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;
  VoidCallback? onNetworkError;

  bool _isInitialized = false;
  bool _isDisposed = false;
  bool isLoading = false;
  String? errorMessage;

  int totalVerifiedUsers = 0;
  int totalUnverifiedUsers = 0;
  int totalCategories = 0;
  int totalReports = 0;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await loadStats();
  }

  Future<void> loadStats() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _usersRepository.search(
          UsersSearchRequestApiModel(pageNumber: 1, pageSize: 1),
        ),
        _ssoRepository.search(
          SsoSearchRequestApiModel(pageNumber: 1, pageSize: 1),
        ),
        _categoryRepository.search(
          CategorySearchRequestApiModel(pageNumber: 1, pageSize: 1),
        ),
        _reportRepository.search(
          ReportSearchRequestApiModel(pageNumber: 1, pageSize: 1),
        ),
      ]);

      totalVerifiedUsers = results[0].totalRecords;
      totalUnverifiedUsers = results[1].totalRecords;
      totalCategories = results[2].totalRecords;
      totalReports = results[3].totalRecords;

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

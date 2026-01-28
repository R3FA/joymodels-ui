import 'package:flutter/material.dart';
import 'package:joymodels_desktop/core/di/di.dart';
import 'package:joymodels_desktop/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/network_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_desktop/data/model/category/request_types/category_request_api_model.dart';
import 'package:joymodels_desktop/data/model/community_post/request_types/community_post_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/models/request_types/model_admin_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/order/request_types/order_admin_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/report/request_types/report_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/sso/request_types/sso_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/users/request_types/user_search_request_api_model.dart';
import 'package:joymodels_desktop/data/repositories/category_repository.dart';
import 'package:joymodels_desktop/data/repositories/community_post_repository.dart';
import 'package:joymodels_desktop/data/repositories/model_repository.dart';
import 'package:joymodels_desktop/data/repositories/order_repository.dart';
import 'package:joymodels_desktop/data/repositories/report_repository.dart';
import 'package:joymodels_desktop/data/repositories/sso_repository.dart';
import 'package:joymodels_desktop/data/repositories/users_repository.dart';

class DashboardPageViewModel with ChangeNotifier {
  final _usersRepository = sl<UsersRepository>();
  final _ssoRepository = sl<SsoRepository>();
  final _modelRepository = sl<ModelRepository>();
  final _categoryRepository = sl<CategoryRepository>();
  final _reportRepository = sl<ReportRepository>();
  final _orderRepository = sl<OrderRepository>();
  final _communityPostRepository = sl<CommunityPostRepository>();

  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;

  bool _isInitialized = false;
  bool isLoading = false;
  String? errorMessage;

  int totalVerifiedUsers = 0;
  int totalUnverifiedUsers = 0;
  int totalModels = 0;
  int totalCategories = 0;
  int totalReports = 0;
  int totalOrders = 0;
  int totalCommunityPosts = 0;

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await loadStats();
  }

  void clearErrorMessage() {
    errorMessage = null;
    notifyListeners();
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
        _modelRepository.adminSearch(
          ModelAdminSearchRequestApiModel(pageNumber: 1, pageSize: 1),
        ),
        _categoryRepository.search(
          CategorySearchRequestApiModel(pageNumber: 1, pageSize: 1),
        ),
        _reportRepository.search(
          ReportSearchRequestApiModel(pageNumber: 1, pageSize: 1),
        ),
        _orderRepository.adminSearch(
          OrderAdminSearchRequestApiModel(pageNumber: 1, pageSize: 1),
        ),
        _communityPostRepository.search(
          CommunityPostSearchRequestApiModel(pageNumber: 1, pageSize: 1),
        ),
      ]);

      totalVerifiedUsers = results[0].totalRecords;
      totalUnverifiedUsers = results[1].totalRecords;
      totalModels = results[2].totalRecords;
      totalCategories = results[3].totalRecords;
      totalReports = results[4].totalRecords;
      totalOrders = results[5].totalRecords;
      totalCommunityPosts = results[6].totalRecords;

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
      errorMessage = NetworkException().toString();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to load dashboard stats.';
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    onSessionExpired = null;
    onForbidden = null;
    super.dispose();
  }
}

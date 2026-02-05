import 'package:flutter/material.dart';
import 'package:joymodels_desktop/core/di/di.dart';
import 'package:joymodels_desktop/data/core/exceptions/api_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/network_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_desktop/data/model/category/request_types/category_create_request_api_model.dart';
import 'package:joymodels_desktop/data/model/category/request_types/category_patch_request_api_model.dart';
import 'package:joymodels_desktop/data/model/category/request_types/category_request_api_model.dart';
import 'package:joymodels_desktop/data/model/category/response_types/category_response_api_model.dart';
import 'package:joymodels_desktop/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_desktop/data/repositories/category_repository.dart';
import 'package:joymodels_desktop/ui/core/mixins/pagination_mixin.dart';
import 'package:joymodels_desktop/ui/core/view_model/regex_view_model.dart';

class CategoriesPageViewModel extends ChangeNotifier
    with PaginationMixin<CategoryResponseApiModel> {
  final _categoryRepository = sl<CategoryRepository>();

  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;
  VoidCallback? onNetworkError;

  bool _isInitialized = false;
  bool _isDisposed = false;
  bool isLoading = false;
  String? errorMessage;

  PaginationResponseApiModel<CategoryResponseApiModel>? pagination;
  String searchQuery = '';
  String? searchError;

  static const int _pageSize = 10;

  @override
  PaginationResponseApiModel<CategoryResponseApiModel>? get paginationData =>
      pagination;

  @override
  bool get isLoadingPage => isLoading;

  @override
  Future<void> loadPage(int pageNumber) => searchCategories(page: pageNumber);

  Future<void> init() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await searchCategories();
  }

  void clearErrorMessage() {
    errorMessage = null;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    searchError = query.isEmpty
        ? null
        : RegexValidationViewModel.validateText(query);
    notifyListeners();
  }

  Future<void> searchCategories({int page = 1}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final request = CategorySearchRequestApiModel(
        categoryName: searchQuery.isNotEmpty ? searchQuery : null,
        pageNumber: page,
        pageSize: _pageSize,
      );

      pagination = await _categoryRepository.search(request);
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

  Future<void> createCategory(String name) async {
    try {
      final request = CategoryCreateRequestApiModel(categoryName: name);
      await _categoryRepository.create(request);
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

  Future<void> updateCategory(String uuid, String name) async {
    try {
      final request = CategoryPatchRequestApiModel(
        uuid: uuid,
        categoryName: name,
      );
      await _categoryRepository.patch(request);
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

  Future<void> deleteCategory(String uuid) async {
    try {
      await _categoryRepository.delete(uuid);
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

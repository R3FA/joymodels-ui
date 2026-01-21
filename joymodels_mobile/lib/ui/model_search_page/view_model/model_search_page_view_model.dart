import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/category/request_types/category_request_api_model.dart';
import 'package:joymodels_mobile/data/model/category/response_types/category_response_api_model.dart';
import 'package:joymodels_mobile/data/model/models/request_types/model_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/category_repository.dart';
import 'package:joymodels_mobile/data/repositories/model_repository.dart';
import 'package:joymodels_mobile/ui/core/mixins/pagination_mixin.dart';
import 'package:joymodels_mobile/ui/model_page/view_model/model_page_view_model.dart';
import 'package:joymodels_mobile/ui/model_page/widgets/model_page_screen.dart';
import 'package:joymodels_mobile/ui/model_search_page/widgets/model_search_modal_sort_type_screen.dart';
import 'package:provider/provider.dart';

enum ModelSortType { topSales, priceAsc, priceDesc, nameAz, nameZa }

extension ModelSortTypeQueryParam on ModelSortType {
  String? get queryParam {
    switch (this) {
      case ModelSortType.nameAz:
        return "Name:asc";
      case ModelSortType.nameZa:
        return "Name:desc";
      case ModelSortType.priceAsc:
        return "Price:asc";
      case ModelSortType.priceDesc:
        return "Price:desc";
      // TODO: implement for topSales when needed
      default:
        return null;
    }
  }
}

class ModelSearchPageViewModel
    with ChangeNotifier, PaginationMixin<ModelResponseApiModel> {
  final modelRepository = sl<ModelRepository>();
  final categoryRepository = sl<CategoryRepository>();

  final searchController = TextEditingController();

  ModelSortType? selectedFilterSort;
  String? selectedFilterCategory;

  String? errorMessage;

  bool isLoading = false;
  bool isCategoriesLoading = false;
  bool areModelsLoading = false;

  PaginationResponseApiModel<ModelResponseApiModel>? models;

  PaginationResponseApiModel<CategoryResponseApiModel>? categories;

  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;

  @override
  PaginationResponseApiModel<ModelResponseApiModel>? get paginationData =>
      models;

  @override
  bool get isLoadingPage => areModelsLoading;

  @override
  Future<void> loadPage(int pageNumber) async {
    await searchModels(
      ModelSearchRequestApiModel(
        modelName: searchController.text,
        categoryName: selectedFilterCategory,
        orderBy: selectedFilterSort?.queryParam,
        pageNumber: pageNumber,
        pageSize: 10,
      ),
    );
  }

  Future<void> init({
    CategoryResponseApiModel? selectedCategory,
    String? modelName,
  }) async {
    isLoading = true;

    selectedFilterCategory = selectedCategory?.categoryName;
    selectedFilterSort = null;

    notifyListeners();
    try {
      await getCategories();
      await searchModels(
        ModelSearchRequestApiModel(
          categoryName: selectedCategory?.categoryName,
          modelName: modelName,
          pageNumber: 1,
          pageSize: 10,
        ),
      );
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> getCategories() async {
    errorMessage = null;
    isCategoriesLoading = true;
    notifyListeners();

    try {
      final categoryRequest = CategorySearchRequestApiModel(
        categoryName: null,
        pageNumber: 1,
        pageSize: 50,
      );

      categories = await categoryRepository.search(categoryRequest);
      isCategoriesLoading = false;
      notifyListeners();

      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      isCategoriesLoading = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isCategoriesLoading = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isCategoriesLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> searchModels(ModelSearchRequestApiModel req) async {
    errorMessage = null;
    areModelsLoading = true;
    notifyListeners();

    try {
      final modelRequest = ModelSearchRequestApiModel(
        modelName: req.modelName,
        categoryName: req.categoryName,
        arePrivateUserModelsSearched: req.arePrivateUserModelsSearched,
        pageNumber: req.pageNumber,
        pageSize: 10,
        orderBy: req.orderBy,
      );

      models = await modelRepository.search(modelRequest);
      areModelsLoading = false;
      notifyListeners();

      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      areModelsLoading = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      areModelsLoading = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      areModelsLoading = false;
      notifyListeners();
      return false;
    }
  }

  void onFilterPressed(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) =>
          ModelSearchModalSortTypeScreen(categories: categories!.data),
    );
  }

  String labelForSortType(ModelSortType type) {
    switch (type) {
      case ModelSortType.topSales:
        return "Top sales (naknadno implementirati)";
      case ModelSortType.priceAsc:
        return "Price: Low to High";
      case ModelSortType.priceDesc:
        return "Price: High to Low";
      case ModelSortType.nameAz:
        return "Name: A-Z";
      case ModelSortType.nameZa:
        return "Name: Z-A";
    }
  }

  void onFilterSubmit() {
    final modelSearchRequest = ModelSearchRequestApiModel(
      modelName: searchController.text,
      categoryName: selectedFilterCategory,
      orderBy: selectedFilterSort?.queryParam,
      pageNumber: 1,
      pageSize: 10,
    );

    searchModels(modelSearchRequest);
  }

  void onModelTap(BuildContext context, ModelResponseApiModel model) {
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider(
            create: (_) => ModelPageViewModel(),
            child: ModelPageScreen(loadedModel: model),
          ),
        ),
      );
    }
  }

  void onBackPressed(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    searchController.dispose();
    onSessionExpired = null;
    onForbidden = null;
    super.dispose();
  }
}

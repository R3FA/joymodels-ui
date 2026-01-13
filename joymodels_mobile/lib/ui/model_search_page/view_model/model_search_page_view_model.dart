import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/category/request_types/category_request_api_model.dart';
import 'package:joymodels_mobile/data/model/category/response_types/category_response_api_model.dart';
import 'package:joymodels_mobile/data/model/core/response_types/picture_response_api_model.dart';
import 'package:joymodels_mobile/data/model/models/request_types/model_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/category_repository.dart';
import 'package:joymodels_mobile/data/repositories/model_repository.dart';
import 'package:joymodels_mobile/ui/model_page/widgets/model_page_screen.dart';
import 'package:joymodels_mobile/ui/model_search_page/widgets/model_search_modal_sort_type_screen.dart';

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

class ModelSearchPageViewModel with ChangeNotifier {
  final modelRepository = sl<ModelRepository>();
  final categoryRepository = sl<CategoryRepository>();

  final searchController = TextEditingController();

  ModelResponseApiModel? selectedModel;
  ModelSortType? selectedFilterSort;
  String? selectedFilterCategory;

  String? categoryName;
  String? modelName;
  String? errorMessage;

  bool isLoading = false;
  bool isCategoriesLoading = false;
  bool areModelsLoading = false;
  bool areModelPicturesLoading = false;

  PaginationResponseApiModel<ModelResponseApiModel>? models;
  List<PictureResponse?> modelPictures = List.empty(growable: true);

  PaginationResponseApiModel<CategoryResponseApiModel>? categories;

  VoidCallback? onSessionExpired;

  Future<void> init({
    CategoryResponseApiModel? selectedCategory,
    String? modelName,
  }) async {
    isLoading = true;
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
    } catch (e) {
      errorMessage = e.toString();
      areModelsLoading = false;
      notifyListeners();
      return false;
    }
  }

  void onFilterPressed(
    BuildContext context,
    CategoryResponseApiModel? selectedCategory,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ModelSearchModalSortTypeScreen(
        categories: categories!.data,
        selectedCategory: selectedCategory,
      ),
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
    selectedModel = model;
    notifyListeners();

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ModelPageScreen(loadedModel: model),
        ),
      );
    }
  }

  void onBackPressed(BuildContext context) {
    Navigator.of(context).pop();
  }

  void onPageChanged(int page) {
    if (page == models?.pageNumber) return;

    searchModels(ModelSearchRequestApiModel(pageNumber: page, pageSize: 10));
  }

  @override
  void dispose() {
    searchController.dispose();
    onSessionExpired = null;
    super.dispose();
  }
}

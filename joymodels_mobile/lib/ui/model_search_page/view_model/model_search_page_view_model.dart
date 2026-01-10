import 'package:flutter/material.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/core/response_types/picture_response_api_model.dart';
import 'package:joymodels_mobile/data/model/models/request_types/model_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/model_repository.dart';
import 'package:joymodels_mobile/ui/model_page/widgets/model_page_screen.dart';

enum ModelSortType { bestMatches, topSales, price }

class ModelSearchPageViewModel with ChangeNotifier {
  final modelRepository = sl<ModelRepository>();

  final searchController = TextEditingController();

  ModelResponseApiModel? selectedModel;

  String? categoryName;
  String? modelName;
  String? errorMessage;

  ModelSortType selectedSortType = ModelSortType.bestMatches;

  bool isLoading = false;
  bool areModelsLoading = false;
  bool areModelPicturesLoading = false;

  PaginationResponseApiModel<ModelResponseApiModel>? models;
  List<PictureResponse?> modelPictures = List.empty(growable: true);

  VoidCallback? onSessionExpired;

  Future<void> init({String? categoryName}) async {
    isLoading = true;
    notifyListeners();
    try {
      initializeCategoryName(categoryName: categoryName);
      await searchModels();
      await loadModelsPicture();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  void initializeCategoryName({String? categoryName}) {
    this.categoryName = categoryName;
  }

  Future<bool> searchModels({int pageNumber = 1}) async {
    errorMessage = null;
    areModelsLoading = true;
    notifyListeners();

    try {
      final modelRequest = ModelSearchRequestApiModel(
        modelName: modelName,
        categoryName: categoryName,
        arePrivateUserModelsSearched: false,
        pageNumber: pageNumber,
        pageSize: 10,
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

  Future<bool> loadModelsPicture() async {
    errorMessage = null;
    areModelPicturesLoading = true;
    notifyListeners();

    try {
      for (ModelResponseApiModel model in models?.data ?? []) {
        modelPictures.add(
          await modelRepository.getModelPictures(
            model.uuid,
            model.modelPictures[0].pictureLocation,
          ),
        );
      }

      areModelPicturesLoading = false;
      notifyListeners();

      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      areModelPicturesLoading = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      areModelPicturesLoading = false;
      notifyListeners();
      return false;
    }
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

  void onSortTypeChanged(ModelSortType sortType) {
    if (selectedSortType == sortType) return;

    selectedSortType = sortType;
    notifyListeners();
  }

  void onSearchSubmitted(String query) {
    // TODO: Implementirati
  }

  void onFilterPressed(BuildContext context) {
    // TODO: Implementirati
  }

  void onBackPressed(BuildContext context) {
    Navigator.of(context).pop();
  }

  void onPageChanged(int page) {
    if (page == models?.pageNumber) return;

    searchModels(pageNumber: page);
  }

  @override
  void dispose() {
    searchController.dispose();
    onSessionExpired = null;
    super.dispose();
  }
}

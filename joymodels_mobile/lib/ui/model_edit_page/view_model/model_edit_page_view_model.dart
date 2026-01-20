import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/category/request_types/category_request_api_model.dart';
import 'package:joymodels_mobile/data/model/category/response_types/category_response_api_model.dart';
import 'package:joymodels_mobile/data/model/model_availability/request_types/model_availability_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_availability/response_types/model_availability_response_api_model.dart';
import 'package:joymodels_mobile/data/model/model_picture/response_types/model_picture_response_api_model.dart';
import 'package:joymodels_mobile/data/model/models/request_types/model_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/models/request_types/model_patch_request_api_model.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/category_repository.dart';
import 'package:joymodels_mobile/data/repositories/model_availability_repository.dart';
import 'package:joymodels_mobile/data/repositories/model_repository.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';
import 'package:joymodels_mobile/ui/core/view_model/validation_view_model.dart';

class ModelEditPageViewModel extends ChangeNotifier {
  final ImagePicker _imagePicker = ImagePicker();

  final categoryRepository = sl<CategoryRepository>();
  final modelAvailabilityRepository = sl<ModelAvailabilityRepository>();
  final modelRepository = sl<ModelRepository>();

  static const int maxPhotos = 8;
  static const int maxCategories = 5;

  final categorySearchController = TextEditingController();

  bool isSaving = false;
  bool isCategoriesLoading = false;
  bool isModelAvailabilitiesLoading = false;
  bool get canAddMorePhotos =>
      modelPicturesToInsert.length +
          modelPictures.length -
          modelPicturesToDelete.length <
      maxPhotos;

  String? errorMessage;
  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;

  List<CategoryResponseApiModel> categories = [];
  late ModelResponseApiModel originalModel;

  List<ModelPictureResponseApiModel> modelPictures = [];
  final List<CategoryResponseApiModel> modelsCategories = [];

  PaginationResponseApiModel<ModelAvailabilityResponseApiModel>?
  modelAvailabilities;

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final priceController = TextEditingController();
  ModelAvailabilityResponseApiModel? selectedAvailability;
  final List<String> modelCategoriesToDelete = [];
  final List<String> modelCategoriesToInsert = [];
  final List<ModelFile> modelPicturesToInsert = [];
  final List<String> modelPicturesToDelete = [];

  Future<void> init(ModelResponseApiModel model) async {
    originalModel = model;
    await getCategories();
    selectedModelCategoriesInit();
    await getModelAvailabilities();
    selectedAvailability = model.modelAvailability;

    nameController.text = model.name;
    descriptionController.text = model.description;
    priceController.text = model.price.toString();
    modelPictures = List.from(model.modelPictures);

    notifyListeners();
  }

  Future<void> onAddPhotoPressed() async {
    if (!canAddMorePhotos) {
      errorMessage = 'Maximum $maxPhotos photos allowed';
      notifyListeners();
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final error =
            await ValidationViewModel.validateModelAndCommunityPostPicture(
              bytes,
              image.name,
            );
        if (error != null) {
          errorMessage = error;
          notifyListeners();
          return;
        }
        modelPicturesToInsert.add(ModelFile(bytes: bytes, name: image.name));
        errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Failed to pick image';
      notifyListeners();
    }
  }

  Future<void> onAddMultiplePhotosPressed() async {
    if (!canAddMorePhotos) {
      errorMessage = 'Maximum $maxPhotos photos allowed';
      notifyListeners();
      return;
    }

    try {
      final List<XFile> images = await _imagePicker.pickMultiImage();

      final availableSlots =
          maxPhotos -
          (modelPicturesToInsert.length +
              modelPictures.length -
              modelPicturesToDelete.length);

      final imagesToAdd = images.take(availableSlots).toList();
      int addedCount = 0;

      for (final image in imagesToAdd) {
        final bytes = await image.readAsBytes();
        final error =
            await ValidationViewModel.validateModelAndCommunityPostPicture(
              bytes,
              image.name,
            );
        if (error != null) {
          errorMessage = error;
          continue;
        }
        modelPicturesToInsert.add(ModelFile(bytes: bytes, name: image.name));
        addedCount++;
      }

      if (images.length > availableSlots || addedCount != imagesToAdd.length) {
        errorMessage =
            'Some photos were not added due to limit or validation error. Max is $maxPhotos.';
      } else {
        errorMessage = null;
      }

      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to pick images';
      notifyListeners();
    }
  }

  void onRemovePhoto(ModelFile photo) {
    modelPicturesToInsert.remove(photo);
    errorMessage = null;
    notifyListeners();
  }

  void markPictureForDelete(String pictureLocation) {
    if (!modelPicturesToDelete.contains(pictureLocation)) {
      modelPicturesToDelete.add(pictureLocation);
      notifyListeners();
    }
  }

  void unmarkPictureForDelete(String pictureLocation) {
    modelPicturesToDelete.remove(pictureLocation);
    notifyListeners();
  }

  bool isPictureMarkedForDelete(String pictureLocation) {
    return modelPicturesToDelete.contains(pictureLocation);
  }

  bool showRemoveButtonForServerPicture(String pictureLocation) => true;

  void selectedModelCategoriesInit() {
    modelsCategories.clear();
    for (final modelCat in originalModel.modelCategories) {
      final matching = categories.firstWhere(
        (cat) => cat.uuid == modelCat.uuid,
        orElse: () => CategoryResponseApiModel(
          uuid: modelCat.uuid,
          categoryName: modelCat.categoryName,
        ),
      );
      if (!modelsCategories.any((c) => c.uuid == matching.uuid)) {
        modelsCategories.add(matching);
      }
    }
  }

  Future<bool> getCategories({String? categoryName}) async {
    errorMessage = null;
    isCategoriesLoading = true;
    notifyListeners();

    try {
      final categoryRequest = CategorySearchRequestApiModel(
        categoryName: categoryName,
        pageNumber: 1,
        pageSize: 8,
      );

      final fetchedCategories = await categoryRepository.search(
        categoryRequest,
      );
      categories = fetchedCategories.data;
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

  bool isCategorySelected(String uuid) {
    return modelsCategories.any((cat) => cat.uuid == uuid);
  }

  void onCategoryToggle(CategoryResponseApiModel category) {
    final uuid = category.uuid;
    final wasSelected = modelsCategories.any((cat) => cat.uuid == uuid);
    final wasOnModel = originalModel.modelCategories.any(
      (cat) => cat.uuid == uuid,
    );

    if (wasSelected) {
      modelsCategories.removeWhere((cat) => cat.uuid == uuid);
      modelCategoriesToInsert.remove(uuid);

      if (wasOnModel && !modelCategoriesToDelete.contains(uuid)) {
        modelCategoriesToDelete.add(uuid);
      }
    } else if (modelsCategories.length < 5) {
      modelsCategories.add(category);

      if (!wasOnModel && !modelCategoriesToInsert.contains(uuid)) {
        modelCategoriesToInsert.add(uuid);
      }

      modelCategoriesToDelete.remove(uuid);
    }
    notifyListeners();
  }

  List<CategoryResponseApiModel> combinedCategories(String search) {
    final combinedSet = {for (var c in categories) c.uuid: c};

    for (final sel in modelsCategories) {
      if (!combinedSet.containsKey(sel.uuid)) {
        combinedSet[sel.uuid] = sel;
      }
    }

    final filtered = combinedSet.values.where(
      (cat) =>
          cat.categoryName.toLowerCase().contains(search.trim().toLowerCase()),
    );

    final selectedUuids = modelsCategories.map((c) => c.uuid).toSet();
    final sorted = filtered.toList()
      ..sort((a, b) {
        final aSel = selectedUuids.contains(a.uuid) ? 0 : 1;
        final bSel = selectedUuids.contains(b.uuid) ? 0 : 1;
        return aSel.compareTo(bSel);
      });

    return sorted;
  }

  Future<bool> getModelAvailabilities({String? availabilityName}) async {
    errorMessage = null;
    isModelAvailabilitiesLoading = true;
    notifyListeners();

    try {
      final request = ModelAvailabilitySearchRequestApiModel(
        availabilityName: availabilityName,
        pageNumber: 1,
        pageSize: 4,
      );

      modelAvailabilities = await modelAvailabilityRepository.search(request);
      isModelAvailabilitiesLoading = false;
      notifyListeners();

      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      isModelAvailabilitiesLoading = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isModelAvailabilitiesLoading = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isModelAvailabilitiesLoading = false;
      notifyListeners();
      return false;
    }
  }

  void onAvailabilityChanged(ModelAvailabilityResponseApiModel availability) {
    selectedAvailability = availability;
    notifyListeners();
  }

  bool isFormValid() {
    if (nameController.text != originalModel.name) {
      final nameError = RegexValidationViewModel.validateText(
        nameController.text,
      );
      if (nameError != null) {
        errorMessage = 'Name: $nameError';
        return false;
      }
    }

    if (descriptionController.text != originalModel.description) {
      final descError = RegexValidationViewModel.validateText(
        descriptionController.text,
      );
      if (descError != null) {
        errorMessage = 'Description: $descError';
        return false;
      }
    }

    final priceError = RegexValidationViewModel.validatePrice(
      priceController.text,
    );
    if (priceError != null) {
      errorMessage = 'Price: $priceError';
      return false;
    }

    if (modelsCategories.isEmpty) {
      errorMessage = 'At least one category is required';
      return false;
    }

    if (selectedAvailability == null) {
      errorMessage = 'Availability is required';
      return false;
    }

    final totalPhotos =
        modelPictures.length -
        modelPicturesToDelete.length +
        modelPicturesToInsert.length;
    if (totalPhotos < 1) {
      errorMessage = 'At least one photo is required';
      return false;
    }

    errorMessage = null;
    return true;
  }

  Future<bool> onSubmit(BuildContext context) async {
    if (!isFormValid()) {
      notifyListeners();
      return false;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      final patchRequest = ModelPatchRequestApiModel(
        uuid: originalModel.uuid,
        name: nameController.text != originalModel.name
            ? nameController.text
            : null,
        description: descriptionController.text != originalModel.description
            ? descriptionController.text
            : null,
        price: double.tryParse(priceController.text),
        modelAvailabilityUuid: selectedAvailability?.uuid,
        modelCategoriesToDelete: List<String>.from(modelCategoriesToDelete),
        modelCategoriesToInsert: List<String>.from(modelCategoriesToInsert),
        modelPictureLocationsToDelete: List<String>.from(modelPicturesToDelete),
        modelPicturesToInsert: List.generate(
          modelPicturesToInsert.length,
          (i) => ModelFile(
            bytes: modelPicturesToInsert[i].bytes,
            name: modelPicturesToInsert[i].name,
          ),
        ),
      );

      final patchedModel = await modelRepository.patch(patchRequest);

      isSaving = false;
      notifyListeners();

      if (context.mounted) {
        Navigator.of(context).pop(patchedModel);
      }

      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      isModelAvailabilitiesLoading = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isSaving = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    categorySearchController.dispose();

    categories.clear();
    modelPictures.clear();
    modelsCategories.clear();
    modelCategoriesToDelete.clear();
    modelCategoriesToInsert.clear();
    modelPicturesToInsert.clear();
    modelPicturesToDelete.clear();

    onSessionExpired = null;
    onForbidden = null;

    super.dispose();
  }
}

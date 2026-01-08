import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/category/request_types/category_request_api_model.dart';
import 'package:joymodels_mobile/data/model/category/response_types/category_response_api_model.dart';
import 'package:joymodels_mobile/data/model/model_availability/request_types/model_availability_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_availability/response_types/model_availability_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/category_repository.dart';
import 'package:joymodels_mobile/data/repositories/model_availability_repository.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';
import 'package:joymodels_mobile/ui/core/view_model/validation_view_model.dart';

class ModelCreatePageViewModel with ChangeNotifier {
  final categoryRepository = sl<CategoryRepository>();
  final modelAvailabilityRepository = sl<ModelAvailabilityRepository>();

  VoidCallback? onSessionExpired;

  PaginationResponseApiModel<CategoryResponseApiModel>? categories;
  PaginationResponseApiModel<ModelAvailabilityResponseApiModel>?
  modelAvailabilities;

  final modelNameController = TextEditingController();
  final modelDescriptionController = TextEditingController();
  final modelCategorySearchController = TextEditingController();
  final modelPriceController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  static const int maxPhotos = 8;

  List<Uint8List> selectedPhotos = [];
  List<String> selectedPhotoNames = [];
  List<Map<String, String>> selectedCategories = [];
  ModelAvailabilityResponseApiModel? selectedAvailability;
  Uint8List? selectedModelFile;
  String? selectedModelFileName;

  bool isLoading = false;
  bool isCategoriesLoading = false;
  bool isModelAvailabilitiesLoading = false;
  bool isSubmitting = false;

  String? errorMessage;

  bool get canAddMorePhotos => selectedPhotos.length < maxPhotos;

  int get remainingPhotos => maxPhotos - selectedPhotos.length;

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    await getCategories();
    await getModelAvailabilities();

    isLoading = false;
    notifyListeners();

    modelCategorySearchController.addListener(() {
      notifyListeners();
    });
  }

  bool isFormValid() {
    final nameError = RegexValidationViewModel.validateText(
      modelNameController.text,
    );
    if (nameError != null) {
      errorMessage = 'Name: $nameError';
      return false;
    }

    final descriptionError = RegexValidationViewModel.validateText(
      modelDescriptionController.text,
    );
    if (descriptionError != null) {
      errorMessage = 'Description: $descriptionError';
      return false;
    }

    if (selectedPhotos.isEmpty) {
      errorMessage = 'At least one photo is required';
      return false;
    }

    if (selectedCategories.isEmpty) {
      errorMessage = 'At least one category is required';
      return false;
    }

    for (final cat in selectedCategories) {
      final categoryNameError = RegexValidationViewModel.validateText(
        cat['name'] ?? '',
      );
      if (categoryNameError != null) {
        errorMessage = 'Category: $categoryNameError';
        return false;
      }
    }

    final availabilityError = RegexValidationViewModel.validateText(
      selectedAvailability?.availabilityName ?? '',
    );
    if (availabilityError != null) {
      errorMessage = 'Availability: $availabilityError';
      return false;
    }

    final priceError = RegexValidationViewModel.validatePrice(
      modelPriceController.text,
    );
    if (priceError != null) {
      errorMessage = 'Price: $priceError';
      return false;
    }

    if (selectedModelFile == null) {
      errorMessage = 'Model file is required';
      return false;
    }

    return true;
  }

  // ==================== PHOTOS ====================

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

        selectedPhotos.add(bytes);
        selectedPhotoNames.add(image.name);
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

      final availableSlots = remainingPhotos;
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
        selectedPhotos.add(bytes);
        selectedPhotoNames.add(image.name);
        addedCount++;
      }

      if (images.length > availableSlots || addedCount != imagesToAdd.length) {
        errorMessage =
            'Some photos were not added due to limit or validation error. Max is $maxPhotos';
      } else {
        errorMessage = null;
      }

      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to pick images';
      notifyListeners();
    }
  }

  void onRemovePhoto(int index) {
    if (index >= 0 && index < selectedPhotos.length) {
      selectedPhotos.removeAt(index);
      if (index < selectedPhotoNames.length) {
        selectedPhotoNames.removeAt(index);
      }
      errorMessage = null;
      notifyListeners();
    }
  }

  // ==================== CATEGORIES ====================

  Future<bool> getCategories({String? categoryName}) async {
    errorMessage = null;
    isCategoriesLoading = true;
    notifyListeners();

    try {
      final categoryRequest = CategorySearchRequestApiModel(
        categoryName: categoryName,
        pageNumber: 1,
        pageSize: 9,
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

  void onCategoryToggle(String uuid, String name) {
    if (selectedCategories.length >= 5 &&
        !selectedCategories.any((cat) => cat['uuid'] == uuid)) {
      return;
    }

    final existingCategory = selectedCategories.firstWhere(
      (cat) => cat['uuid'] == uuid,
      orElse: () => {},
    );

    if (existingCategory.isNotEmpty) {
      selectedCategories.remove(existingCategory);
    } else {
      selectedCategories.add({'uuid': uuid, 'name': name});
    }

    notifyListeners();
  }

  bool isCategorySelected(String uuid) {
    return selectedCategories.any((cat) => cat['uuid'] == uuid);
  }

  List<Map<String, String>> filteredCategories(String query) {
    final allCategories =
        categories?.data
            .map((cat) => {'uuid': cat.uuid, 'name': cat.categoryName})
            .where((cat) => cat['name']!.toLowerCase().contains(query))
            .toList() ??
        [];

    final selectedCategoriesOnTop = selectedCategories.map((selected) {
      final existsInAll = allCategories.firstWhere(
        (cat) => cat['uuid'] == selected['uuid'],
        orElse: () => selected,
      );
      return existsInAll;
    }).toList();

    final otherCategories = allCategories
        .where(
          (cat) => !selectedCategoriesOnTop.any(
            (selected) => selected['uuid'] == cat['uuid'],
          ),
        )
        .toList();

    return [...selectedCategoriesOnTop, ...otherCategories];
  }

  // ==================== AVAILABILITY ====================

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
    } catch (e) {
      errorMessage = e.toString();
      isModelAvailabilitiesLoading = false;
      notifyListeners();
      return false;
    }
  }

  void onAvailabilityChanged(ModelAvailabilityResponseApiModel availability) {
    if (selectedAvailability?.uuid == availability.uuid) {
      selectedAvailability = null;
    } else {
      selectedAvailability = availability;
    }

    notifyListeners();
  }

  // ==================== MODEL FILE ====================

  Future<void> onAddModelFilePressed() async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        final validationError = ValidationViewModel.validateModelFile(file);
        if (validationError != null) {
          selectedModelFile = null;
          selectedModelFileName = null;
          errorMessage = validationError;
          notifyListeners();
          return;
        }

        if (file.path != null) {
          final fileData = await _readFileFromPath(file.path!);
          selectedModelFile = fileData;
          selectedModelFileName = file.name;
          errorMessage = null;
          notifyListeners();
        }
      }

      errorMessage = null;
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to pick file: ${e.toString()}';
      selectedModelFile = null;
      selectedModelFileName = null;
      notifyListeners();
    }
  }

  Future<Uint8List?> _readFileFromPath(String path) async {
    try {
      final file = File(path);
      return await file.readAsBytes();
    } catch (e) {
      return null;
    }
  }

  void onRemoveModelFile() {
    selectedModelFile = null;
    selectedModelFileName = null;
    errorMessage = null;
    notifyListeners();
  }

  // ==================== FORM ACTIONS ====================

  Future<void> onSubmit(BuildContext context) async {
    if (!isFormValid()) {
      notifyListeners();
      return;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      // TODO: Pozovi repository za upload modela

      isSubmitting = false;
      notifyListeners();

      // if (context.mounted) {
      //   Navigator.of(context).pop(true);
      // }
    } catch (e) {
      errorMessage = e.toString();
      isSubmitting = false;
      notifyListeners();
    }
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    modelNameController.dispose();
    modelDescriptionController.dispose();
    modelCategorySearchController.dispose();
    modelPriceController.dispose();
    onSessionExpired = null;
    super.dispose();
  }
}

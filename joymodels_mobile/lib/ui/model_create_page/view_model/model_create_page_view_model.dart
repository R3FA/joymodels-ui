import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/network_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/api_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/category/request_types/category_request_api_model.dart';
import 'package:joymodels_mobile/data/model/category/response_types/category_response_api_model.dart';
import 'package:joymodels_mobile/data/model/model_availability/request_types/model_availability_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/model_availability/response_types/model_availability_response_api_model.dart';
import 'package:joymodels_mobile/data/model/models/request_types/model_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/category_repository.dart';
import 'package:joymodels_mobile/data/repositories/model_availability_repository.dart';
import 'package:joymodels_mobile/data/repositories/model_repository.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';
import 'package:joymodels_mobile/ui/core/view_model/validation_view_model.dart';
import 'package:joymodels_mobile/ui/model_page/view_model/model_page_view_model.dart';
import 'package:joymodels_mobile/ui/model_page/widgets/model_page_screen.dart';
import 'package:provider/provider.dart';

class ModelCreatePageViewModel with ChangeNotifier {
  final categoryRepository = sl<CategoryRepository>();
  final modelAvailabilityRepository = sl<ModelAvailabilityRepository>();
  final modelRepository = sl<ModelRepository>();

  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;

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

  String? nameError;
  String? descriptionError;
  String? priceError;
  String? photosError;
  String? categoriesError;
  String? availabilityError;
  String? modelFileError;

  bool get canAddMorePhotos => selectedPhotos.length < maxPhotos;

  int get remainingPhotos => maxPhotos - selectedPhotos.length;

  bool get isFormComplete =>
      modelNameController.text.trim().isNotEmpty &&
      modelDescriptionController.text.trim().isNotEmpty &&
      selectedPhotos.isNotEmpty &&
      selectedCategories.isNotEmpty &&
      selectedAvailability != null &&
      modelPriceController.text.trim().isNotEmpty &&
      selectedModelFile != null;

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    await getCategories();
    await getModelAvailabilities();

    modelPriceController.text = '0.00';

    isLoading = false;
    notifyListeners();

    modelNameController.addListener(_onFormChanged);
    modelDescriptionController.addListener(_onFormChanged);
    modelPriceController.addListener(_onFormChanged);
    modelCategorySearchController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    clearFieldErrors();
    notifyListeners();
  }

  void clearFieldErrors() {
    nameError = null;
    descriptionError = null;
    priceError = null;
    photosError = null;
    categoriesError = null;
    availabilityError = null;
    modelFileError = null;
  }

  bool isFormValid() {
    clearFieldErrors();
    bool valid = true;

    final nameValidation = RegexValidationViewModel.validateText(
      modelNameController.text,
    );
    if (nameValidation != null) {
      nameError = nameValidation;
      valid = false;
    }

    final descriptionValidation = RegexValidationViewModel.validateText(
      modelDescriptionController.text,
    );
    if (descriptionValidation != null) {
      descriptionError = descriptionValidation;
      valid = false;
    }

    if (selectedPhotos.isEmpty) {
      photosError = 'At least one photo is required';
      valid = false;
    }

    if (selectedCategories.isEmpty) {
      categoriesError = 'At least one category is required';
      valid = false;
    }

    if (selectedAvailability == null) {
      availabilityError = 'Availability is required';
      valid = false;
    }

    final priceValidation = RegexValidationViewModel.validatePrice(
      modelPriceController.text,
    );
    if (priceValidation != null) {
      priceError = priceValidation;
      valid = false;
    }

    if (selectedModelFile == null) {
      modelFileError = 'Model file is required';
      valid = false;
    }

    return valid;
  }

  Future<void> onAddPhotoPressed() async {
    if (!canAddMorePhotos) {
      photosError = 'Maximum $maxPhotos photos allowed';
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
          photosError = error;
          notifyListeners();
          return;
        }

        selectedPhotos.add(bytes);
        selectedPhotoNames.add(image.name);
        photosError = null;
        notifyListeners();
      }
    } catch (e) {
      photosError = 'Failed to pick image';
      notifyListeners();
    }
  }

  Future<void> onAddMultiplePhotosPressed() async {
    if (!canAddMorePhotos) {
      photosError = 'Maximum $maxPhotos photos allowed';
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
          photosError = error;
          continue;
        }
        selectedPhotos.add(bytes);
        selectedPhotoNames.add(image.name);
        addedCount++;
      }

      if (images.length > availableSlots || addedCount != imagesToAdd.length) {
        photosError =
            'Some photos were not added due to limit or validation error. Max is $maxPhotos';
      } else {
        photosError = null;
      }

      notifyListeners();
    } catch (e) {
      photosError = 'Failed to pick images';
      notifyListeners();
    }
  }

  void onRemovePhoto(int index) {
    if (index >= 0 && index < selectedPhotos.length) {
      selectedPhotos.removeAt(index);
      if (index < selectedPhotoNames.length) {
        selectedPhotoNames.removeAt(index);
      }
      photosError = null;
      notifyListeners();
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
    } on ForbiddenException {
      isCategoriesLoading = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isCategoriesLoading = false;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      errorMessage = e.message;
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

    categoriesError = null;
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
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isModelAvailabilitiesLoading = false;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      errorMessage = e.message;
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

    availabilityError = null;
    notifyListeners();
  }

  Future<void> onAddModelFilePressed() async {
    try {
      final result = await FilePicker.platform.pickFiles();

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        final validationError = ValidationViewModel.validateModelFile(file);
        if (validationError != null) {
          selectedModelFile = null;
          selectedModelFileName = null;
          modelFileError = validationError;
          notifyListeners();
          return;
        }

        if (file.path != null) {
          final fileData = await _readFileFromPath(file.path!);
          selectedModelFile = fileData;
          selectedModelFileName = file.name;
          modelFileError = null;
          notifyListeners();
        }
      }
    } catch (e) {
      modelFileError = 'Failed to pick file: ${e.toString()}';
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
    modelFileError = null;
    notifyListeners();
  }

  Future<bool> onSubmit(BuildContext context) async {
    if (!isFormValid()) {
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final request = ModelCreateRequestApiModel(
        name: modelNameController.text,
        description: modelDescriptionController.text,
        pictures: List.generate(
          selectedPhotos.length,
          (i) =>
              ModelFile(bytes: selectedPhotos[i], name: selectedPhotoNames[i]),
        ),
        price: double.parse(modelPriceController.text),
        modelAvailabilityUuid: selectedAvailability!.uuid,
        modelCategoryUuids: selectedCategories
            .map((cat) => cat['uuid']!)
            .toList(),
        model: ModelFile(
          bytes: selectedModelFile!,
          name: selectedModelFileName!,
        ),
      );

      final createdModel = await modelRepository.create(request);

      isSubmitting = false;
      notifyListeners();

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ChangeNotifierProvider(
              create: (_) => ModelPageViewModel(),
              child: ModelPageScreen(loadedModel: createdModel),
            ),
          ),
        );
      }

      clearForm();

      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      isSubmitting = false;
      notifyListeners();
      onSessionExpired?.call();
      clearForm();
      return false;
    } on ForbiddenException {
      isSubmitting = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isSubmitting = false;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      errorMessage = e.message;
      isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    errorMessage = null;
    clearFieldErrors();
    notifyListeners();
  }

  void clearForm() {
    modelNameController.clear();
    modelDescriptionController.clear();
    modelCategorySearchController.clear();
    modelPriceController.text = '0.00';

    selectedPhotos.clear();
    selectedPhotoNames.clear();
    selectedCategories.clear();
    selectedAvailability = null;
    selectedModelFile = null;
    selectedModelFileName = null;

    isLoading = false;
    isCategoriesLoading = false;
    isModelAvailabilitiesLoading = false;
    isSubmitting = false;
    errorMessage = null;
    clearFieldErrors();

    notifyListeners();
  }

  @override
  void dispose() {
    modelNameController.dispose();
    modelDescriptionController.dispose();
    modelCategorySearchController.dispose();
    modelPriceController.dispose();
    onSessionExpired = null;
    onForbidden = null;
    super.dispose();
  }
}

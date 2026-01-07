import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/category/request_types/category_request_api_model.dart';
import 'package:joymodels_mobile/data/model/category/response_types/category_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/category_repository.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';

enum ModelAvailability { store, communityChallenge }

class ModelCreatePageViewModel with ChangeNotifier {
  final categoryRepository = sl<CategoryRepository>();

  VoidCallback? onSessionExpired;

  PaginationResponseApiModel<CategoryResponseApiModel>? categories;

  final modelNameController = TextEditingController();
  final modelDescriptionController = TextEditingController();
  final modelCategorySearchController = TextEditingController();
  final modelPriceController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  static const int maxPhotos = 8;

  List<Uint8List> selectedPhotos = [];
  List<Map<String, String>> selectedCategories = [];
  ModelAvailability? selectedAvailability;

  Uint8List? selectedModelFile;
  String? selectedModelFileName;

  bool isLoading = false;
  bool isCategoriesLoading = false;
  bool isSubmitting = false;

  String? errorMessage;

  bool get canAddMorePhotos => selectedPhotos.length < maxPhotos;

  int get remainingPhotos => maxPhotos - selectedPhotos.length;

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    await getCategories();

    isLoading = false;
    notifyListeners();

    modelCategorySearchController.addListener(() {
      notifyListeners();
    });
  }

  bool get isFormValid {
    return RegexValidationViewModel.validateText(modelNameController.text) ==
            null &&
        RegexValidationViewModel.validateText(
              modelDescriptionController.text,
            ) ==
            null &&
        RegexValidationViewModel.validatePrice(modelPriceController.text) ==
            null;
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
        selectedPhotos.add(bytes);
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
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      final availableSlots = remainingPhotos;
      final imagesToAdd = images.take(availableSlots).toList();

      for (final image in imagesToAdd) {
        final bytes = await image.readAsBytes();
        selectedPhotos.add(bytes);
      }

      if (images.length > availableSlots) {
        errorMessage =
            'Only $availableSlots photos were added. Maximum is $maxPhotos';
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

  void onAvailabilityChanged(ModelAvailability availability) {
    if (selectedAvailability == availability) {
      selectedAvailability = null;
      notifyListeners();
      return;
    }

    selectedAvailability = availability;
    notifyListeners();
  }

  // ==================== MODEL FILE ====================

  // ✅ NOVA IMPLEMENTACIJA: File picker za 3D model
  Future<void> onAddModelFilePressed() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        // Možeš specificirati tipove ako želiš samo 3D fajlove:
        // type: FileType.custom,
        // allowedExtensions: ['glb', 'gltf', 'obj', 'fbx', 'stl'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        if (file.bytes != null) {
          selectedModelFile = file.bytes;
          selectedModelFileName = file.name;
        } else if (file.path != null) {
          // Za mobile uređaje, čitaj fajl sa path-a
          final fileData = await _readFileFromPath(file.path!);
          if (fileData != null) {
            selectedModelFile = fileData;
            selectedModelFileName = file.name;
          }
        }

        errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      errorMessage = 'Failed to pick file:  ${e.toString()}';
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
    notifyListeners();
  }

  // ==================== FORM ACTIONS ====================

  Future<void> onSubmit(BuildContext context) async {
    if (!isFormValid) {
      errorMessage = 'Please fill all required fields';
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

      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
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
    modelPriceController.dispose();
    modelCategorySearchController.dispose();
    super.dispose();
  }
}

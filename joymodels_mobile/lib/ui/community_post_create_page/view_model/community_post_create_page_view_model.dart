import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/network_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/api_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/community_post/request_types/community_post_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post_type/request_types/community_post_type_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/community_post_type/response_types/community_post_type_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/community_post_repository.dart';
import 'package:joymodels_mobile/data/repositories/community_post_type_repository.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';
import 'package:joymodels_mobile/ui/core/view_model/validation_view_model.dart';

class CommunityPostCreatePageViewModel with ChangeNotifier {
  final communityPostRepository = sl<CommunityPostRepository>();
  final communityPostTypeRepository = sl<CommunityPostTypeRepository>();

  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;

  PaginationResponseApiModel<CommunityPostTypeResponseApiModel>? postTypes;

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final youtubeVideoLinkController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  static const int maxPhotos = 4;

  List<Uint8List> selectedPhotos = [];
  List<String> selectedPhotoNames = [];
  CommunityPostTypeResponseApiModel? selectedPostType;

  bool isLoading = false;
  bool isPostTypesLoading = false;
  bool isSubmitting = false;

  String? errorMessage;

  String? titleError;
  String? descriptionError;
  String? postTypeError;
  String? youtubeError;
  String? photosError;

  bool get canAddMorePhotos => selectedPhotos.length < maxPhotos;

  int get remainingPhotos => maxPhotos - selectedPhotos.length;

  bool get isFormComplete =>
      titleController.text.trim().isNotEmpty &&
      descriptionController.text.trim().isNotEmpty &&
      selectedPostType != null;

  Future<void> init() async {
    isLoading = true;
    notifyListeners();

    await getPostTypes();

    isLoading = false;
    notifyListeners();

    titleController.addListener(_onFormChanged);
    descriptionController.addListener(_onFormChanged);
    youtubeVideoLinkController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    clearFieldErrors();
    notifyListeners();
  }

  void clearFieldErrors() {
    titleError = null;
    descriptionError = null;
    postTypeError = null;
    youtubeError = null;
    photosError = null;
  }

  bool isFormValid() {
    clearFieldErrors();
    bool valid = true;

    final titleValidation = RegexValidationViewModel.validateText(
      titleController.text,
    );
    if (titleValidation != null) {
      titleError = titleValidation;
      valid = false;
    }

    if (titleController.text.length > 100) {
      titleError = 'Title cannot exceed 100 characters';
      valid = false;
    }

    final descriptionValidation = RegexValidationViewModel.validateText(
      descriptionController.text,
    );
    if (descriptionValidation != null) {
      descriptionError = descriptionValidation;
      valid = false;
    }

    if (descriptionController.text.length > 5000) {
      descriptionError = 'Description cannot exceed 5000 characters';
      valid = false;
    }

    if (selectedPostType == null) {
      postTypeError = 'Post type is required';
      valid = false;
    }

    if (youtubeVideoLinkController.text.isNotEmpty) {
      if (youtubeVideoLinkController.text.length > 2048) {
        youtubeError = 'YouTube video link cannot exceed 2048 characters';
        valid = false;
      }

      final youtubeValidation =
          RegexValidationViewModel.validateYoutubeVideoLink(
            youtubeVideoLinkController.text,
          );
      if (youtubeValidation != null) {
        youtubeError = youtubeValidation;
        valid = false;
      }
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

  Future<bool> getPostTypes({String? postTypeName}) async {
    errorMessage = null;
    isPostTypesLoading = true;
    notifyListeners();

    try {
      final request = CommunityPostTypeSearchRequestApiModel(
        postTypeName: postTypeName,
        pageNumber: 1,
        pageSize: 10,
      );

      postTypes = await communityPostTypeRepository.search(request);
      isPostTypesLoading = false;
      notifyListeners();

      return true;
    } on SessionExpiredException {
      errorMessage = SessionExpiredException().toString();
      isPostTypesLoading = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isPostTypesLoading = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isPostTypesLoading = false;
      notifyListeners();
      return false;
    } on ApiException catch (e) {
      errorMessage = e.message;
      isPostTypesLoading = false;
      notifyListeners();
      return false;
    }
  }

  void onPostTypeChanged(CommunityPostTypeResponseApiModel postType) {
    if (selectedPostType?.uuid == postType.uuid) {
      selectedPostType = null;
    } else {
      selectedPostType = postType;
    }

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
      final request = CommunityPostCreateRequestApiModel(
        title: titleController.text,
        description: descriptionController.text,
        postTypeUuid: selectedPostType!.uuid,
        youtubeVideoLink: youtubeVideoLinkController.text.isNotEmpty
            ? youtubeVideoLinkController.text
            : null,
        pictures: selectedPhotos.isNotEmpty
            ? List.generate(
                selectedPhotos.length,
                (i) => CommunityPostPictureFile(
                  bytes: selectedPhotos[i],
                  name: selectedPhotoNames[i],
                ),
              )
            : null,
      );

      await communityPostRepository.create(request);

      isSubmitting = false;
      notifyListeners();

      if (context.mounted) {
        Navigator.of(context).pop(true);
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
    titleController.clear();
    descriptionController.clear();
    youtubeVideoLinkController.clear();

    selectedPhotos.clear();
    selectedPhotoNames.clear();
    selectedPostType = null;

    isLoading = false;
    isPostTypesLoading = false;
    isSubmitting = false;
    errorMessage = null;
    clearFieldErrors();

    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    youtubeVideoLinkController.dispose();
    onSessionExpired = null;
    onForbidden = null;
    super.dispose();
  }
}

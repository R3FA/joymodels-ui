import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:joymodels_mobile/core/di/di.dart';
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/network_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/model/library/request_types/library_search_request_api_model.dart';
import 'package:joymodels_mobile/data/model/library/response_types/library_response_api_model.dart';
import 'package:joymodels_mobile/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_mobile/data/repositories/library_repository.dart';
import 'package:joymodels_mobile/ui/core/mixins/pagination_mixin.dart';
import 'package:joymodels_mobile/ui/core/view_model/regex_view_model.dart';

class LibraryPageViewModel extends ChangeNotifier
    with PaginationMixin<LibraryResponseApiModel> {
  final _libraryRepository = sl<LibraryRepository>();

  bool isLoading = false;
  bool isDownloading = false;
  String? downloadingModelUuid;
  String? errorMessage;
  String? searchErrorMessage;
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  PaginationResponseApiModel<LibraryResponseApiModel>? libraryPagination;
  List<LibraryResponseApiModel> get libraryItems =>
      libraryPagination?.data ?? [];

  VoidCallback? onSessionExpired;
  VoidCallback? onForbidden;

  static const int _pageSize = 10;

  @override
  PaginationResponseApiModel<LibraryResponseApiModel>? get paginationData =>
      libraryPagination;

  @override
  bool get isLoadingPage => isLoading;

  @override
  Future<void> loadPage(int pageNumber) async {
    await loadLibrary(pageNumber: pageNumber);
  }

  Future<void> init({String? initialSearchQuery}) async {
    if (initialSearchQuery != null && initialSearchQuery.isNotEmpty) {
      searchQuery = initialSearchQuery;
      searchController.text = initialSearchQuery;
    }
    await loadLibrary();
  }

  Future<bool> loadLibrary({int? pageNumber}) async {
    if (searchQuery.isNotEmpty) {
      final validationError = RegexValidationViewModel.validateText(
        searchQuery,
      );
      if (validationError != null) {
        searchErrorMessage = validationError;
        libraryPagination = null;
        notifyListeners();
        return false;
      }
    }

    errorMessage = null;
    searchErrorMessage = null;
    isLoading = true;
    notifyListeners();

    try {
      final request = LibrarySearchRequestApiModel(
        modelName: searchQuery.isNotEmpty ? searchQuery : null,
        pageNumber: pageNumber ?? currentPage,
        pageSize: _pageSize,
      );

      libraryPagination = await _libraryRepository.search(request);
      isLoading = false;
      notifyListeners();

      return true;
    } on SessionExpiredException {
      errorMessage = 'Session expired. Please login again.';
      isLoading = false;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isLoading = false;
      notifyListeners();
      onForbidden?.call();
      return false;
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void onSearchChanged(String query) {
    searchQuery = query;

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      loadLibrary(pageNumber: 1);
    });
  }

  void clearSearch() {
    searchQuery = '';
    searchController.clear();
    searchErrorMessage = null;
    loadLibrary(pageNumber: 1);
  }

  Future<bool> downloadModel(
    BuildContext context,
    LibraryResponseApiModel libraryItem,
  ) async {
    if (isDownloading) return false;

    isDownloading = true;
    downloadingModelUuid = libraryItem.model.uuid;
    notifyListeners();

    try {
      final rawBytes = await _libraryRepository.downloadModel(
        libraryItem.model.uuid,
      );
      final bytes = Uint8List.fromList(rawBytes);

      final extension = _getFileExtension(bytes);
      final fileName =
          '${libraryItem.model.name.replaceAll(RegExp(r'[^\w\s-]'), '_')}$extension';

      final params = SaveFileDialogParams(data: bytes, fileName: fileName);
      final savedPath = await FlutterFileDialog.saveFile(params: params);

      isDownloading = false;
      downloadingModelUuid = null;
      notifyListeners();

      if (savedPath != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('${libraryItem.model.name} saved!')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      return savedPath != null;
    } on SessionExpiredException {
      isDownloading = false;
      downloadingModelUuid = null;
      notifyListeners();
      onSessionExpired?.call();
      return false;
    } on ForbiddenException {
      isDownloading = false;
      downloadingModelUuid = null;
      notifyListeners();
      onForbidden?.call();
      return false;
    } on NetworkException {
      errorMessage = NetworkException().toString();
      isDownloading = false;
      downloadingModelUuid = null;
      notifyListeners();
      return false;
    } catch (e) {
      isDownloading = false;
      downloadingModelUuid = null;
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Download failed: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      return false;
    }
  }

  bool isModelDownloading(String modelUuid) {
    return isDownloading && downloadingModelUuid == modelUuid;
  }

  String _getFileExtension(Uint8List bytes) {
    if (bytes.length < 12) {
      return '.bin';
    }

    final header = String.fromCharCodes(bytes.take(80));

    if (bytes[0] == 0x50 && bytes[1] == 0x4B) {
      return '.zip';
    }

    if (bytes[0] == 0x67 &&
        bytes[1] == 0x6C &&
        bytes[2] == 0x54 &&
        bytes[3] == 0x46) {
      return '.glb';
    }

    if (bytes[0] == 0x7B && header.contains('"asset"')) {
      return '.gltf';
    }

    if (header.contains('Kaydara FBX Binary')) {
      return '.fbx';
    }

    if (header.startsWith('; FBX')) {
      return '.fbx';
    }

    if (header.startsWith('# ') ||
        header.startsWith('v ') ||
        header.startsWith('vt ') ||
        header.startsWith('vn ')) {
      return '.obj';
    }

    if (header.toLowerCase().startsWith('solid')) {
      return '.stl';
    }

    if (header.startsWith('BLENDER')) {
      return '.blend';
    }

    if (header.startsWith('FOR4') || header.startsWith('FOR8')) {
      return '.mb';
    }

    if (header.contains('Maya ASCII')) {
      return '.ma';
    }

    if (bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return '.webp';
    }

    if (bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return '.png';
    }

    if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
      return '.jpg';
    }

    return '.bin';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    onSessionExpired = null;
    onForbidden = null;
    super.dispose();
  }
}

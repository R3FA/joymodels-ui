import 'dart:convert';
import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/model/library/request_types/library_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/library/response_types/library_response_api_model.dart';
import 'package:joymodels_desktop/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_desktop/data/services/library_service.dart';

class LibraryRepository {
  final LibraryService _service;
  final AuthService _authService;

  LibraryRepository(this._service, this._authService);

  Future<LibraryResponseApiModel> getByUuid(String libraryUuid) async {
    final response = await _authService.request(
      () => _service.getByUuid(libraryUuid),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return LibraryResponseApiModel.fromJson(jsonMap);
    } else if (response.statusCode == 404) {
      throw Exception('Library entry not found');
    } else {
      throw Exception(
        'Failed to fetch library entry: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<LibraryResponseApiModel> getByModelUuid(String modelUuid) async {
    final response = await _authService.request(
      () => _service.getByModelUuid(modelUuid),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return LibraryResponseApiModel.fromJson(jsonMap);
    } else if (response.statusCode == 404) {
      throw Exception('Model not found in library');
    } else {
      throw Exception(
        'Failed to fetch library entry: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PaginationResponseApiModel<LibraryResponseApiModel>> search(
    LibrarySearchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.search(request));

    if (response.statusCode == 200) {
      if (response.body.isEmpty || response.body == 'null') {
        return PaginationResponseApiModel<LibraryResponseApiModel>(
          data: [],
          pageNumber: 1,
          pageSize: request.pageSize,
          totalPages: 0,
          totalRecords: 0,
          hasPreviousPage: false,
          hasNextPage: false,
          orderBy: request.orderBy,
        );
      }

      try {
        final decoded = jsonDecode(response.body);
        if (decoded == null) {
          return PaginationResponseApiModel<LibraryResponseApiModel>(
            data: [],
            pageNumber: 1,
            pageSize: request.pageSize,
            totalPages: 0,
            totalRecords: 0,
            hasPreviousPage: false,
            hasNextPage: false,
            orderBy: request.orderBy,
          );
        }

        final jsonMap = decoded as Map<String, dynamic>;
        return PaginationResponseApiModel.fromJson(
          jsonMap,
          (json) => LibraryResponseApiModel.fromJson(json),
        );
      } catch (e) {
        throw Exception(
          'Failed to parse library response: $e\nBody: ${response.body}',
        );
      }
    } else {
      throw Exception(
        'Failed to fetch library: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<bool> hasPurchasedModel(String modelUuid) async {
    final response = await _authService.request(
      () => _service.hasPurchasedModel(modelUuid),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as bool;
    } else {
      throw Exception(
        'Failed to check purchase status: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<List<int>> downloadModel(String modelUuid) async {
    final response = await _authService.request(
      () => _service.downloadModel(modelUuid),
    );

    if (response.statusCode == 200) {
      return response.bodyBytes.toList();
    } else if (response.statusCode == 404) {
      throw Exception('Model file not found');
    } else if (response.statusCode == 403) {
      throw Exception('You do not own this model');
    } else {
      throw Exception(
        'Failed to download model: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

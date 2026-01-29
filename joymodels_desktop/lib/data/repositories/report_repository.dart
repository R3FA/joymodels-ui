import 'dart:convert';
import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_desktop/data/model/report/request_types/report_patch_status_request_api_model.dart';
import 'package:joymodels_desktop/data/model/report/request_types/report_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/report/response_types/report_response_api_model.dart';
import 'package:joymodels_desktop/data/services/report_service.dart';

class ReportRepository {
  final ReportService _service;
  final AuthService _authService;

  ReportRepository(this._service, this._authService);

  Future<PaginationResponseApiModel<ReportResponseApiModel>> search(
    ReportSearchRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.search(request));

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return PaginationResponseApiModel<ReportResponseApiModel>.fromJson(
        jsonMap,
        (item) => ReportResponseApiModel.fromJson(item),
      );
    } else {
      throw Exception(
        'Failed to search reports: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<ReportResponseApiModel> patchStatus(
    ReportPatchStatusRequestApiModel request,
  ) async {
    final response = await _authService.request(
      () => _service.patchStatus(request),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body);
      return ReportResponseApiModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to patch report status: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

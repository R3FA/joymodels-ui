import 'dart:convert';
import 'package:joymodels_desktop/data/core/services/auth_service.dart';
import 'package:joymodels_desktop/data/model/pagination/response_types/pagination_response_api_model.dart';
import 'package:joymodels_desktop/data/model/report/request_types/report_create_request_api_model.dart';
import 'package:joymodels_desktop/data/model/report/request_types/report_search_request_api_model.dart';
import 'package:joymodels_desktop/data/model/report/response_types/report_response_api_model.dart';
import 'package:joymodels_desktop/data/services/report_service.dart';

class ReportRepository {
  final ReportService _service;
  final AuthService _authService;

  ReportRepository(this._service, this._authService);

  Future<ReportResponseApiModel> create(
    ReportCreateRequestApiModel request,
  ) async {
    final response = await _authService.request(() => _service.create(request));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return ReportResponseApiModel.fromJson(jsonMap);
    } else if (response.statusCode == 400) {
      final body = jsonDecode(response.body);
      throw Exception(
        body['detail'] ?? body['message'] ?? 'Invalid report request',
      );
    } else {
      throw Exception(
        'Failed to create report: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<PaginationResponseApiModel<ReportResponseApiModel>> myReports(
    ReportSearchRequestApiModel request,
  ) async {
    final response = await _authService.request(
      () => _service.myReports(request),
    );

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return PaginationResponseApiModel.fromJson(
        jsonMap,
        (json) => ReportResponseApiModel.fromJson(json),
      );
    } else {
      throw Exception(
        'Failed to fetch my reports: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> delete(String reportUuid) async {
    final response = await _authService.request(
      () => _service.delete(reportUuid),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete report: ${response.statusCode} - ${response.body}',
      );
    }
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:joymodels_desktop/data/core/config/api_constants.dart';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';
import 'package:joymodels_desktop/data/model/report/request_types/report_create_request_api_model.dart';
import 'package:joymodels_desktop/data/model/report/request_types/report_search_request_api_model.dart';

class ReportService {
  final String reportUrl = "${ApiConstants.baseUrl}/reports";

  Future<http.Response> create(ReportCreateRequestApiModel request) async {
    final url = Uri.parse("$reportUrl/create");
    final token = await TokenStorage.getAccessToken();

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(request.toJson()),
    );

    return response;
  }

  Future<http.Response> myReports(ReportSearchRequestApiModel request) async {
    final queryParams = request.toQueryParameters();
    final uri = Uri.parse(
      "$reportUrl/my-reports",
    ).replace(queryParameters: queryParams);
    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }

  Future<http.Response> delete(String reportUuid) async {
    final url = Uri.parse("$reportUrl/delete/$reportUuid");
    final token = await TokenStorage.getAccessToken();

    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }
}

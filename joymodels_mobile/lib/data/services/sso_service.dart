import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_user_create_request_api_model.dart';

class SsoService {
  final String ssoUrl = "${ApiConstants.baseUrl}/sso";

  Future<http.Response> create(SsoUserCreateRequestApiModel request) async {
    final url = Uri.parse("$ssoUrl/create");

    final multiPartRequest = await request.toMultipartRequest(url);

    final streamedResponse = await multiPartRequest.send();

    final response = await http.Response.fromStream(streamedResponse);

    return response;
  }
}

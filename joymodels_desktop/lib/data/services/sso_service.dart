import 'package:http/http.dart' as http;
import 'package:joymodels_desktop/data/core/config/api_constants.dart';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';
import 'package:joymodels_desktop/data/model/sso/request_types/sso_access_token_change_request_api_model.dart';
import 'package:joymodels_desktop/data/model/sso/request_types/sso_logout_request_api_model.dart';
import 'package:joymodels_desktop/data/model/sso/request_types/sso_user_login_request_api_model.dart';

class SsoService {
  final String ssoUrl = "${ApiConstants.baseUrl}/sso";

  Future<http.Response> adminLogin(SsoUserLoginRequestApiModel request) async {
    final url = Uri.parse("$ssoUrl/admin-login");

    final multiPartRequest = await request.toMultipartRequest(url);

    final streamedResponse = await multiPartRequest.send();

    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> requestAccessTokenChange(
    SsoAccessTokenChangeRequestApiModel request,
  ) async {
    final url = Uri.parse('$ssoUrl/request-access-token-change');

    final multipartRequest = await request.toMultipartRequest(url);

    final streamedResponse = await multipartRequest.send();

    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> logout(SsoLogoutRequestApiModel request) async {
    final url = Uri.parse('$ssoUrl/logout');

    final multiPartRequest = await request.toMultipartRequest(url);

    final token = await TokenStorage.getAccessToken();
    multiPartRequest.headers['Authorization'] = "Bearer $token";

    final streamedResponse = await multiPartRequest.send();

    return await http.Response.fromStream(streamedResponse);
  }
}

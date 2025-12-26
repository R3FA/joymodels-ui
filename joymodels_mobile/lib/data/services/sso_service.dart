import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_new_otp_code_request_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_user_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_user_login_request_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_verify_request_api_model.dart';

class SsoService {
  final String ssoUrl = "${ApiConstants.baseUrl}/sso";

  Future<http.Response> create(SsoUserCreateRequestApiModel request) async {
    final url = Uri.parse("$ssoUrl/create");

    final multiPartRequest = await request.toMultipartRequest(url);

    final streamedResponse = await multiPartRequest.send();

    final response = await http.Response.fromStream(streamedResponse);

    return response;
  }

  Future<http.Response> verify(SsoVerifyRequestApiModel request) async {
    final url = Uri.parse("$ssoUrl/verify");

    final multiPartRequest = await request.toMultipartRequest(url);

    final token = await TokenStorage.getAccessToken();
    multiPartRequest.headers['Authorization'] = "Bearer $token";

    final streamedResponse = await multiPartRequest.send();

    final response = await http.Response.fromStream(streamedResponse);

    return response;
  }

  Future<http.Response> requestNewOtpCode(
    SsoNewOtpCodeRequestApiModel request,
  ) async {
    final url = Uri.parse("$ssoUrl/request-new-otp-code");

    final multiPartRequest = await request.toMultipartRequest(url);

    final token = await TokenStorage.getAccessToken();
    multiPartRequest.headers['Authorization'] = "Bearer $token";

    final streamedResponse = await multiPartRequest.send();

    final response = await http.Response.fromStream(streamedResponse);

    return response;
  }

  Future<http.Response> login(SsoUserLoginRequestApiModel request) async {
    final url = Uri.parse("$ssoUrl/login");

    final multiPartRequest = await request.toMultipartRequest(url);

    final streamedResponse = await multiPartRequest.send();

    final response = await http.Response.fromStream(streamedResponse);

    return response;
  }
}

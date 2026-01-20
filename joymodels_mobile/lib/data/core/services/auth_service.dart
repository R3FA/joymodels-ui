import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/core/repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _authRepository;

  AuthService(this._authRepository);

  Future<http.Response> request(
    Future<http.Response> Function() request,
  ) async {
    http.Response response = await request();

    if (response.statusCode == 401) {
      final refreshed = await _authRepository.requestAccessTokenChange();
      if (refreshed) {
        response = await request();
      } else {
        throw SessionExpiredException();
      }
    }

    if (response.statusCode == 403) {
      throw ForbiddenException();
    }

    return response;
  }

  Future<http.StreamedResponse> requestStreamed(
    Future<http.StreamedResponse> Function() request,
  ) async {
    http.StreamedResponse response = await request();

    if (response.statusCode == 401) {
      final refreshed = await _authRepository.requestAccessTokenChange();
      if (refreshed) {
        response = await request();
      } else {
        throw SessionExpiredException();
      }
    }

    if (response.statusCode == 403) {
      throw ForbiddenException();
    }

    return response;
  }
}

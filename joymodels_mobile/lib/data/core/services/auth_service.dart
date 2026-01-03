import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_mobile/data/core/repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _authRepository;

  AuthService(this._authRepository);

  Future<http.Response> request(
    Future<http.Response> Function() request,
  ) async {
    http.Response response = await request();

    // TODO: Add Forbidden Exception handling
    if (response.statusCode == 401) {
      final refreshed = await _authRepository.requestAccessTokenChange();
      if (refreshed) {
        response = await request();
      } else {
        throw SessionExpiredException();
      }
    }

    return response;
  }
}

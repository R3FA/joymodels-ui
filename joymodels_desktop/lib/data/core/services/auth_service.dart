import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:joymodels_desktop/data/core/exceptions/api_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/forbidden_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/network_exception.dart';
import 'package:joymodels_desktop/data/core/exceptions/session_expired_exception.dart';
import 'package:joymodels_desktop/data/core/repositories/auth_repository.dart';
import 'package:joymodels_desktop/data/model/core/response_types/problem_details_response_api_model.dart';

class AuthService {
  final AuthRepository _authRepository;

  AuthService(this._authRepository);

  Future<http.Response> request(
    Future<http.Response> Function() request,
  ) async {
    http.Response response;

    try {
      response = await request();
    } on SocketException {
      throw NetworkException();
    }

    if (response.statusCode == 401) {
      final refreshed = await _authRepository.requestAccessTokenChange();
      if (refreshed) {
        try {
          response = await request();
        } on SocketException {
          throw NetworkException();
        }
      } else {
        throw SessionExpiredException();
      }
    }

    if (response.statusCode == 403) {
      throw ForbiddenException();
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw _parseApiException(response.body, response.statusCode);
    }

    return response;
  }

  ApiException _parseApiException(String body, int statusCode) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      return ApiException(ProblemDetailsResponseApiModel.fromJson(json));
    } catch (_) {
      return ApiException(
        ProblemDetailsResponseApiModel(
          status: statusCode,
          detail: 'An unexpected error occurred.',
        ),
      );
    }
  }
}

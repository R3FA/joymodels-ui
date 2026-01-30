import 'package:joymodels_mobile/data/model/core/response_types/problem_details_response_api_model.dart';

class ApiException implements Exception {
  final ProblemDetailsResponseApiModel problemDetails;

  ApiException(this.problemDetails);

  String get message =>
      problemDetails.detail ?? 'An unexpected error occurred.';

  @override
  String toString() => message;
}

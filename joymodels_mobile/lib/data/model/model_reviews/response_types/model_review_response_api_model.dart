import 'package:joymodels_mobile/data/model/model_review_type/response_types/model_review_type_response_api_model.dart';
import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/data/model/users/response_types/users_response_api_model.dart';

class ModelReviewResponseApiModel {
  final String uuid;
  final ModelResponseApiModel modelResponse;
  final UsersResponseApiModel usersResponse;
  final ModelReviewTypeResponseApiModel modelReviewTypeResponse;
  final String modelReviewText;
  final DateTime createdAt;

  ModelReviewResponseApiModel({
    required this.uuid,
    required this.modelResponse,
    required this.usersResponse,
    required this.modelReviewTypeResponse,
    required this.modelReviewText,
    required this.createdAt,
  });

  factory ModelReviewResponseApiModel.fromJson(Map<String, dynamic> json) {
    return ModelReviewResponseApiModel(
      uuid: json['uuid'],
      modelResponse: ModelResponseApiModel.fromJson(json['modelResponse']),
      usersResponse: UsersResponseApiModel.fromJson(json['usersResponse']),
      modelReviewTypeResponse: ModelReviewTypeResponseApiModel.fromJson(
        json['modelReviewTypeResponse'],
      ),
      modelReviewText: json['modelReviewText'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

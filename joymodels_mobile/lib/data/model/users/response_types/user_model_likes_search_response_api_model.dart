import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';

class UserModelLikesSearchResponseApiModel {
  final String uuid;
  final ModelResponseApiModel modelResponse;

  UserModelLikesSearchResponseApiModel({
    required this.uuid,
    required this.modelResponse,
  });

  factory UserModelLikesSearchResponseApiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserModelLikesSearchResponseApiModel(
      uuid: json['uuid'] as String,
      modelResponse: ModelResponseApiModel.fromJson(json['modelResponse']),
    );
  }
}

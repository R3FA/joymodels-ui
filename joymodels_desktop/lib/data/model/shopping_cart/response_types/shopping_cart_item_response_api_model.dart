import 'package:joymodels_desktop/data/model/models/response_types/model_response_api_model.dart';

class ShoppingCartItemResponseApiModel {
  final String uuid;
  final ModelResponseApiModel model;
  final DateTime createdAt;

  ShoppingCartItemResponseApiModel({
    required this.uuid,
    required this.model,
    required this.createdAt,
  });

  factory ShoppingCartItemResponseApiModel.fromJson(Map<String, dynamic> json) {
    return ShoppingCartItemResponseApiModel(
      uuid: json['uuid'],
      model: ModelResponseApiModel.fromJson(json['model']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

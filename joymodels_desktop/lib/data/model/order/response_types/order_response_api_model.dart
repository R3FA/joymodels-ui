import 'package:joymodels_desktop/data/model/models/response_types/model_response_api_model.dart';

class OrderResponseApiModel {
  final String uuid;
  final ModelResponseApiModel model;
  final double amount;
  final String status;
  final String stripePaymentIntentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderResponseApiModel({
    required this.uuid,
    required this.model,
    required this.amount,
    required this.status,
    required this.stripePaymentIntentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderResponseApiModel.fromJson(Map<String, dynamic> json) {
    return OrderResponseApiModel(
      uuid: json['uuid'],
      model: ModelResponseApiModel.fromJson(json['model']),
      amount: (json['amount'] as num).toDouble(),
      status: json['status'],
      stripePaymentIntentId: json['stripePaymentIntentId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

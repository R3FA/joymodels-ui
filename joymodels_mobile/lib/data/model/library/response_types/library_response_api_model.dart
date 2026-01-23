import 'package:joymodels_mobile/data/model/models/response_types/model_response_api_model.dart';
import 'package:joymodels_mobile/data/model/order/response_types/order_response_api_model.dart';

class LibraryResponseApiModel {
  final String uuid;
  final ModelResponseApiModel model;
  final OrderResponseApiModel order;
  final DateTime acquiredAt;

  LibraryResponseApiModel({
    required this.uuid,
    required this.model,
    required this.order,
    required this.acquiredAt,
  });

  factory LibraryResponseApiModel.fromJson(Map<String, dynamic> json) {
    return LibraryResponseApiModel(
      uuid: json['uuid'],
      model: ModelResponseApiModel.fromJson(json['model']),
      order: OrderResponseApiModel.fromJson(json['order']),
      acquiredAt: DateTime.parse(json['acquiredAt']),
    );
  }
}

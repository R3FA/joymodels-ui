class OrderConfirmResponseApiModel {
  final bool success;
  final String message;
  final String? orderUuid;

  OrderConfirmResponseApiModel({
    required this.success,
    required this.message,
    this.orderUuid,
  });

  factory OrderConfirmResponseApiModel.fromJson(Map<String, dynamic> json) {
    return OrderConfirmResponseApiModel(
      success: json['success'],
      message: json['message'],
      orderUuid: json['orderUuid'],
    );
  }
}

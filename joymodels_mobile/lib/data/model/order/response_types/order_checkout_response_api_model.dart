class OrderCheckoutResponseApiModel {
  final String clientSecret;
  final String ephemeralKey;
  final String customerId;
  final String paymentIntentId;

  OrderCheckoutResponseApiModel({
    required this.clientSecret,
    required this.ephemeralKey,
    required this.customerId,
    required this.paymentIntentId,
  });

  factory OrderCheckoutResponseApiModel.fromJson(Map<String, dynamic> json) {
    return OrderCheckoutResponseApiModel(
      clientSecret: json['clientSecret'],
      ephemeralKey: json['ephemeralKey'],
      customerId: json['customerId'],
      paymentIntentId: json['paymentIntentId'],
    );
  }
}

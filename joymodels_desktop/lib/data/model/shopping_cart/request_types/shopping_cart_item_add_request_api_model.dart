class ShoppingCartItemAddRequestApiModel {
  final String modelUuid;

  ShoppingCartItemAddRequestApiModel({required this.modelUuid});

  Map<String, String> toFormData() {
    return {'modelUuid': modelUuid};
  }
}

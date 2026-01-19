class ModelFaqSectionCreateRequestApiModel {
  final String modelUuid;
  final String messageText;

  ModelFaqSectionCreateRequestApiModel({
    required this.modelUuid,
    required this.messageText,
  });

  Map<String, String> toFormData() {
    return {'modelUuid': modelUuid, 'messageText': messageText};
  }
}

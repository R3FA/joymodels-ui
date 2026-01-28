class ModelFaqSectionCreateAnswerRequestApiModel {
  final String modelUuid;
  final String parentMessageUuid;
  final String messageText;

  ModelFaqSectionCreateAnswerRequestApiModel({
    required this.modelUuid,
    required this.parentMessageUuid,
    required this.messageText,
  });

  Map<String, String> toFormData() {
    return {
      'modelUuid': modelUuid,
      'parentMessageUuid': parentMessageUuid,
      'messageText': messageText,
    };
  }
}

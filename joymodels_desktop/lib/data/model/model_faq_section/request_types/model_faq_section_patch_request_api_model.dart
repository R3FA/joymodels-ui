class ModelFaqSectionPatchRequestApiModel {
  final String modelFaqSectionUuid;
  final String modelUuid;
  final String messageText;

  ModelFaqSectionPatchRequestApiModel({
    required this.modelFaqSectionUuid,
    required this.modelUuid,
    required this.messageText,
  });

  Map<String, String> toFormData() {
    return {
      'modelFaqSectionUuid': modelFaqSectionUuid,
      'modelUuid': modelUuid,
      'messageText': messageText,
    };
  }
}

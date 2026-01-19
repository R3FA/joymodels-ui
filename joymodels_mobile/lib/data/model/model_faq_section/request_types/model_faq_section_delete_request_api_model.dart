class ModelFaqSectionDeleteRequestApiModel {
  final String modelFaqSectionUuid;

  ModelFaqSectionDeleteRequestApiModel({required this.modelFaqSectionUuid});

  Map<String, String> toFormData() {
    return {'modelFaqSectionUuid': modelFaqSectionUuid};
  }
}

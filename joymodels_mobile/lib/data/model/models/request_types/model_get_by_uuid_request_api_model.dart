class ModelGetByUuidRequestApiModel {
  final String modelUuid;
  final bool arePrivateModelsSearched;

  ModelGetByUuidRequestApiModel({
    required this.modelUuid,
    this.arePrivateModelsSearched = false,
  });

  Map<String, String> toQueryParameters() {
    return {
      'modelUuid': modelUuid,
      'arePrivateModelsSearched': arePrivateModelsSearched.toString(),
    };
  }
}

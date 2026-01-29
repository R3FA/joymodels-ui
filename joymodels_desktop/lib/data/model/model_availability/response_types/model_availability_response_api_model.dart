class ModelAvailabilityResponseApiModel {
  final String uuid;
  final String availabilityName;

  ModelAvailabilityResponseApiModel({
    required this.uuid,
    required this.availabilityName,
  });

  factory ModelAvailabilityResponseApiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return ModelAvailabilityResponseApiModel(
      uuid: json['uuid'],
      availabilityName: json['availabilityName'],
    );
  }
}

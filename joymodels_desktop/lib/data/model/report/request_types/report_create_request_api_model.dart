class ReportCreateRequestApiModel {
  final String reportedEntityType;
  final String reportedEntityUuid;
  final String reason;
  final String? description;

  ReportCreateRequestApiModel({
    required this.reportedEntityType,
    required this.reportedEntityUuid,
    required this.reason,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'reportedEntityType': reportedEntityType,
      'reportedEntityUuid': reportedEntityUuid,
      'reason': reason,
      if (description != null && description!.isNotEmpty)
        'description': description,
    };
  }
}

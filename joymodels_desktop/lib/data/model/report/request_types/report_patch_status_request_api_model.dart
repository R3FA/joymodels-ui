class ReportPatchStatusRequestApiModel {
  final String reportUuid;
  final String status;

  ReportPatchStatusRequestApiModel({
    required this.reportUuid,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {'reportUuid': reportUuid, 'status': status};
  }
}

import 'package:joymodels_mobile/data/model/users/response_types/users_response_api_model.dart';

class ReportResponseApiModel {
  final String uuid;
  final UsersResponseApiModel reporter;
  final String reportedEntityType;
  final String reportedEntityUuid;
  final String reason;
  final String? description;
  final String status;
  final UsersResponseApiModel? reviewedBy;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  ReportResponseApiModel({
    required this.uuid,
    required this.reporter,
    required this.reportedEntityType,
    required this.reportedEntityUuid,
    required this.reason,
    this.description,
    required this.status,
    this.reviewedBy,
    this.reviewedAt,
    required this.createdAt,
  });

  factory ReportResponseApiModel.fromJson(Map<String, dynamic> json) {
    return ReportResponseApiModel(
      uuid: json['uuid'],
      reporter: UsersResponseApiModel.fromJson(json['reporter']),
      reportedEntityType: json['reportedEntityType'],
      reportedEntityUuid: json['reportedEntityUuid'],
      reason: json['reason'],
      description: json['description'],
      status: json['status'],
      reviewedBy: json['reviewedBy'] != null
          ? UsersResponseApiModel.fromJson(json['reviewedBy'])
          : null,
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

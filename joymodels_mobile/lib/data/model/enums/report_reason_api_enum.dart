enum ReportReasonApiEnum {
  spam,
  inappropriate,
  harassment,
  copyright,
  other;

  String toApiString() {
    switch (this) {
      case ReportReasonApiEnum.spam:
        return 'Spam';
      case ReportReasonApiEnum.inappropriate:
        return 'Inappropriate';
      case ReportReasonApiEnum.harassment:
        return 'Harassment';
      case ReportReasonApiEnum.copyright:
        return 'Copyright';
      case ReportReasonApiEnum.other:
        return 'Other';
    }
  }

  static ReportReasonApiEnum fromApiString(String value) {
    switch (value) {
      case 'Spam':
        return ReportReasonApiEnum.spam;
      case 'Inappropriate':
        return ReportReasonApiEnum.inappropriate;
      case 'Harassment':
        return ReportReasonApiEnum.harassment;
      case 'Copyright':
        return ReportReasonApiEnum.copyright;
      case 'Other':
        return ReportReasonApiEnum.other;
      default:
        return ReportReasonApiEnum.other;
    }
  }

  String get displayName {
    switch (this) {
      case ReportReasonApiEnum.spam:
        return 'Spam';
      case ReportReasonApiEnum.inappropriate:
        return 'Inappropriate Content';
      case ReportReasonApiEnum.harassment:
        return 'Harassment';
      case ReportReasonApiEnum.copyright:
        return 'Copyright Violation';
      case ReportReasonApiEnum.other:
        return 'Other';
    }
  }
}

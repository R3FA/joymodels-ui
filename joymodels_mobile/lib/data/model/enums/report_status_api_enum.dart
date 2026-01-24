enum ReportStatusApiEnum {
  pending,
  reviewed,
  resolved,
  dismissed;

  String toApiString() {
    switch (this) {
      case ReportStatusApiEnum.pending:
        return 'Pending';
      case ReportStatusApiEnum.reviewed:
        return 'Reviewed';
      case ReportStatusApiEnum.resolved:
        return 'Resolved';
      case ReportStatusApiEnum.dismissed:
        return 'Dismissed';
    }
  }

  static ReportStatusApiEnum fromApiString(String value) {
    switch (value) {
      case 'Pending':
        return ReportStatusApiEnum.pending;
      case 'Reviewed':
        return ReportStatusApiEnum.reviewed;
      case 'Resolved':
        return ReportStatusApiEnum.resolved;
      case 'Dismissed':
        return ReportStatusApiEnum.dismissed;
      default:
        return ReportStatusApiEnum.pending;
    }
  }
}

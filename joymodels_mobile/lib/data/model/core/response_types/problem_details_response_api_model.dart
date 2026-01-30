class ProblemDetailsResponseApiModel {
  final String? type;
  final String? title;
  final String? detail;
  final int? status;
  final String? instance;

  ProblemDetailsResponseApiModel({
    this.type,
    this.title,
    this.detail,
    this.status,
    this.instance,
  });

  factory ProblemDetailsResponseApiModel.fromJson(Map<String, dynamic> json) {
    return ProblemDetailsResponseApiModel(
      type: json['type'] as String?,
      title: json['title'] as String?,
      detail: json['detail'] as String?,
      status: json['status'] as int?,
      instance: json['instance'] as String?,
    );
  }
}

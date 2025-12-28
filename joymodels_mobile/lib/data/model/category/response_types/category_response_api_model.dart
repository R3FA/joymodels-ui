class CategoryResponseApiModel {
  final String uuid;
  final String categoryName;

  CategoryResponseApiModel({required this.uuid, required this.categoryName});

  factory CategoryResponseApiModel.fromJson(Map<String, dynamic> json) {
    return CategoryResponseApiModel(
      uuid: json['uuid'] as String,
      categoryName: json['categoryName'] as String,
    );
  }
}

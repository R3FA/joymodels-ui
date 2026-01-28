enum ModelReviewEnum {
  all(0),
  negative(1),
  positive(2),
  mixed(3);

  final int value;
  const ModelReviewEnum(this.value);

  String toJson() => value.toString();

  static ModelReviewEnum fromValue(int value) {
    return ModelReviewEnum.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ModelReviewEnum.all,
    );
  }
}

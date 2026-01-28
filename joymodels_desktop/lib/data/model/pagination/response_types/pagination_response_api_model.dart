class PaginationResponseApiModel<T> {
  final int pageNumber;
  final int pageSize;
  final int totalRecords;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final String? orderBy;
  final List<T> data;

  PaginationResponseApiModel({
    required this.pageNumber,
    required this.pageSize,
    required this.totalRecords,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
    required this.orderBy,
    required this.data,
  });

  factory PaginationResponseApiModel.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginationResponseApiModel<T>(
      pageNumber: json['pageNumber'],
      pageSize: json['pageSize'],
      totalRecords: json['totalRecords'],
      totalPages: json['totalPages'],
      hasPreviousPage: json['hasPreviousPage'],
      hasNextPage: json['hasNextPage'],
      orderBy: json['orderBy'],
      data: (json['data'] as List)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

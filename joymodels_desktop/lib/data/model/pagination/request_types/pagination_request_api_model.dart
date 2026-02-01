abstract class PaginationRequestApiModel {
  int pageNumber;
  int pageSize;
  String? orderBy;

  PaginationRequestApiModel({
    this.pageNumber = 1,
    this.pageSize = 5,
    this.orderBy,
  });

  Map<String, dynamic> toJson() => {
    'pageNumber': pageNumber,
    'pageSize': pageSize,
    if (orderBy != null) 'orderBy': orderBy,
  };

  Map<String, String> toQueryParameters() {
    return {
      'pageNumber': pageNumber.toString(),
      'pageSize': pageSize.toString(),
      'orderBy': ?orderBy,
    };
  }
}

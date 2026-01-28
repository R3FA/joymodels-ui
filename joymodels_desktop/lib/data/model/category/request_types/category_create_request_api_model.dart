import 'package:http/http.dart' as http;

class CategoryCreateRequestApiModel {
  final String categoryName;

  CategoryCreateRequestApiModel({required this.categoryName});

  Future<http.MultipartRequest> toMultipartRequest(Uri url) async {
    final request = http.MultipartRequest('POST', url);
    request.fields['CategoryName'] = categoryName;
    return request;
  }
}

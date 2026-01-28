import 'package:http/http.dart' as http;

class CategoryPatchRequestApiModel {
  final String uuid;
  final String categoryName;

  CategoryPatchRequestApiModel({
    required this.uuid,
    required this.categoryName,
  });

  Future<http.MultipartRequest> toMultipartRequest(Uri url) async {
    final request = http.MultipartRequest('PATCH', url);
    request.fields['Uuid'] = uuid;
    request.fields['CategoryName'] = categoryName;
    return request;
  }
}

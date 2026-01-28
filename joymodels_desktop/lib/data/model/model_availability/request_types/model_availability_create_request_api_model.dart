import 'package:http/http.dart' as http;

class ModelAvailabilityCreateRequestApiModel {
  final String availabilityName;

  ModelAvailabilityCreateRequestApiModel({required this.availabilityName});

  Future<http.MultipartRequest> toMultipartRequest(Uri url) async {
    final request = http.MultipartRequest('POST', url);
    request.fields['AvailabilityName'] = availabilityName;
    return request;
  }
}

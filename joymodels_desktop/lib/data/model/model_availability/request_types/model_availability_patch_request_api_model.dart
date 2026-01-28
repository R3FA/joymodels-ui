import 'package:http/http.dart' as http;

class ModelAvailabilityPatchRequestApiModel {
  final String uuid;
  final String availabilityName;

  ModelAvailabilityPatchRequestApiModel({
    required this.uuid,
    required this.availabilityName,
  });

  Future<http.MultipartRequest> toMultipartRequest(Uri url) async {
    final request = http.MultipartRequest('PATCH', url);
    request.fields['Uuid'] = uuid;
    request.fields['AvailabilityName'] = availabilityName;
    return request;
  }
}

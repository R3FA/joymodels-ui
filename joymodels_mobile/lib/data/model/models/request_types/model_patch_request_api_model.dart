import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/model/models/request_types/model_create_request_api_model.dart';

class ModelPatchRequestApiModel {
  final String uuid;
  final String? name;
  final String? description;
  final double? price;
  final String? modelAvailabilityUuid;
  final List<String> modelCategoriesToDelete;
  final List<String> modelCategoriesToInsert;
  final List<String> modelPictureLocationsToDelete;
  final List<ModelFile> modelPicturesToInsert;

  ModelPatchRequestApiModel({
    required this.uuid,
    this.name,
    this.description,
    this.price,
    this.modelAvailabilityUuid,
    List<String>? modelCategoriesToDelete,
    List<String>? modelCategoriesToInsert,
    List<String>? modelPictureLocationsToDelete,
    List<ModelFile>? modelPicturesToInsert,
  }) : modelCategoriesToDelete = modelCategoriesToDelete ?? [],
       modelCategoriesToInsert = modelCategoriesToInsert ?? [],
       modelPictureLocationsToDelete = modelPictureLocationsToDelete ?? [],
       modelPicturesToInsert = modelPicturesToInsert ?? [];

  Future<http.MultipartRequest> toMultipartRequest(
    Uri uri, {
    String method = 'PATCH',
  }) async {
    final req = http.MultipartRequest(method, uri);

    req.fields['Uuid'] = uuid;
    if (name != null) req.fields['Name'] = name!;
    if (description != null) req.fields['Description'] = description!;
    if (price != null) req.fields['Price'] = price.toString();
    if (modelAvailabilityUuid != null) {
      req.fields['ModelAvailabilityUuid'] = modelAvailabilityUuid!;
    }

    for (int i = 0; i < modelCategoriesToInsert.length; i++) {
      req.fields['ModelCategoriesToInsert[$i]'] = modelCategoriesToInsert[i];
    }

    for (int i = 0; i < modelCategoriesToDelete.length; i++) {
      req.fields['ModelCategoriesToDelete[$i]'] = modelCategoriesToDelete[i];
    }

    for (int i = 0; i < modelPictureLocationsToDelete.length; i++) {
      req.fields['ModelPictureLocationsToDelete[$i]'] =
          modelPictureLocationsToDelete[i];
    }

    for (final pic in modelPicturesToInsert) {
      req.files.add(
        http.MultipartFile.fromBytes(
          'ModelPictureToInsert',
          pic.bytes,
          filename: pic.name,
        ),
      );
    }

    return req;
  }
}

import 'dart:typed_data';

import 'package:http/http.dart' as http;

class ModelFile {
  final Uint8List bytes;
  final String name;

  ModelFile({required this.bytes, required this.name});
}

class ModelCreateRequestApiModel {
  final String name;
  final List<ModelFile> pictures;
  final String description;
  final double price;
  final String modelAvailabilityUuid;
  final List<String> modelCategoryUuids;
  final ModelFile model;

  ModelCreateRequestApiModel({
    required this.name,
    required this.pictures,
    required this.description,
    required this.price,
    required this.modelAvailabilityUuid,
    required this.modelCategoryUuids,
    required this.model,
  });

  Future<http.MultipartRequest> toMultipartRequest(Uri uri) async {
    final req = http.MultipartRequest('POST', uri);

    req.fields['Name'] = name;
    req.fields['Description'] = description;
    req.fields['Price'] = price.toString();
    req.fields['ModelAvailabilityUuid'] = modelAvailabilityUuid;

    for (int i = 0; i < modelCategoryUuids.length; i++) {
      req.fields['ModelCategoryUuids[$i]'] = modelCategoryUuids[i];
    }

    for (final pic in pictures) {
      req.files.add(
        http.MultipartFile.fromBytes('Pictures', pic.bytes, filename: pic.name),
      );
    }

    req.files.add(
      http.MultipartFile.fromBytes('Model', model.bytes, filename: model.name),
    );

    return req;
  }
}

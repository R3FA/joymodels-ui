import 'dart:convert';
import 'dart:typed_data';

class PictureResponse {
  final Uint8List fileBytes;
  final String contentType;

  PictureResponse({required this.fileBytes, required this.contentType});

  factory PictureResponse.fromJson(Map<String, dynamic> json) {
    return PictureResponse(
      fileBytes: base64Decode(json['fileBytes'] as String),
      contentType: json['contentType'] as String,
    );
  }
}

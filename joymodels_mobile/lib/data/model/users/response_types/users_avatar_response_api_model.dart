import 'dart:convert';
import 'dart:typed_data';

class UsersAvatarResponse {
  final Uint8List fileBytes;
  final String contentType;

  UsersAvatarResponse({required this.fileBytes, required this.contentType});

  factory UsersAvatarResponse.fromJson(Map<String, dynamic> json) {
    return UsersAvatarResponse(
      fileBytes: base64Decode(json['fileBytes'] as String),
      contentType: json['contentType'] as String,
    );
  }
}

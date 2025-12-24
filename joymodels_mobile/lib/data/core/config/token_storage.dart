import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'accessToken';

  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<void> clearAccessToken() async {
    await _storage.delete(key: _accessTokenKey);
  }

  static Future<void> setNewAccessToken(String token) async {
    await clearAccessToken();
    await saveAccessToken(token);
  }

  Future<bool> hasAccessToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Map<String, dynamic> decodeAccessToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token format');
    }

    final String payload = utf8.decode(
      base64Url.decode(base64Url.normalize(parts[1])),
    );
    final Map<String, dynamic> accessTokenPayloadMap = json.decode(payload);

    return accessTokenPayloadMap;
  }
}

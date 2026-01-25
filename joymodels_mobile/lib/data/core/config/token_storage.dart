import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:joymodels_mobile/data/model/enums/jwt_claim_key_api_enum.dart';
import 'package:joymodels_mobile/data/model/enums/user_role_api_enum.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<bool> setNewAuthToken(
    String accessToken,
    String refreshToken,
  ) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> setNewAccessToken(String accessToken) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> clearAuthToken() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hasAuthToken() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null &&
        accessToken.isNotEmpty &&
        refreshToken != null &&
        refreshToken.isNotEmpty;
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

  static Future<String?> getClaimFromToken(JwtClaimKeyApiEnum claimKey) async {
    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken == null) return null;

    final accessTokenPayloadMap = TokenStorage.decodeAccessToken(accessToken);
    return accessTokenPayloadMap[claimKey.key] as String?;
  }

  static Future<String?> getCurrentUserUuid() async {
    return await getClaimFromToken(JwtClaimKeyApiEnum.nameIdentifier);
  }

  static Future<String?> getCurrentUserName() async {
    return await getClaimFromToken(JwtClaimKeyApiEnum.userName);
  }

  static Future<String?> getCurrentUserRole() async {
    return await getClaimFromToken(JwtClaimKeyApiEnum.role);
  }

  static Future<bool> isAdminOrRoot() async {
    final role = await getCurrentUserRole();
    if (role == null) return false;
    return role == UserRoleApiEnum.Root.name ||
        role == UserRoleApiEnum.Admin.name;
  }
}

import 'dart:convert';
import 'package:joymodels_desktop/data/core/config/token_storage.dart';
import 'package:joymodels_desktop/data/model/enums/jwt_claim_key_api_enum.dart';
import 'package:joymodels_desktop/data/model/sso/request_types/sso_access_token_change_request_api_model.dart';
import 'package:joymodels_desktop/data/model/sso/response_types/sso_access_token_change_response_api_model.dart';
import 'package:joymodels_desktop/data/services/sso_service.dart';

class AuthRepository {
  final SsoService _ssoService;

  AuthRepository(this._ssoService);

  Future<bool> requestAccessTokenChange() async {
    if (!(await TokenStorage.hasAuthToken())) {
      return false;
    }

    final userUuid = await TokenStorage.getClaimFromToken(
      JwtClaimKeyApiEnum.nameIdentifier,
    );
    final refreshToken = await TokenStorage.getRefreshToken();

    if (userUuid == null && refreshToken == null) {
      return false;
    }

    final request = SsoAccessTokenChangeRequestApiModel(
      userUuid: userUuid!,
      userRefreshToken: refreshToken!,
    );

    final response = await _ssoService.requestAccessTokenChange(request);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final tokenResponse = SsoAccessTokenChangeResponseApiModel.fromJson(
        jsonData,
      );

      await TokenStorage.setNewAccessToken(tokenResponse.userAccessToken);
      return true;
    } else {
      await TokenStorage.clearAuthToken();
      return false;
    }
  }
}

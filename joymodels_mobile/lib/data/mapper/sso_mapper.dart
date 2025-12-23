import 'package:joymodels_mobile/data/mapper/user_role_mapper.dart';
import 'package:joymodels_mobile/data/model/sso/request_types/sso_user_create_request_api_model.dart';
import 'package:joymodels_mobile/data/model/sso/response_types/sso_user_response_api_model.dart';
import 'package:joymodels_mobile/domain/models/sso/request_types/sso_user_create_request.dart';
import 'package:joymodels_mobile/domain/models/sso/response_types/sso_user_response.dart';

// Mapper: DOMAIN -> DATA DTO
extension SsoUserCreateRequestDomainToApiModel on SsoUserCreateRequest {
  SsoUserCreateRequestApiModel toApiModel() => SsoUserCreateRequestApiModel(
    firstName: firstName,
    lastName: lastName,
    nickname: nickname,
    email: email,
    password: password,
    userPicture: userPicture,
  );
}

// Mapper: DATA -> DOMAIN DTO
extension SsoUserResponseApiModelToDomain on SsoUserResponseApiModel {
  SsoUserResponse toDomain() {
    return SsoUserResponse(
      uuid: uuid,
      firstName: firstName,
      lastName: lastName,
      nickname: nickName,
      email: email,
      created: createdAt,
      accessToken: userAccessToken,
      pictureUrl: userPictureLocation,
      userRole: userRole.toDomain(),
    );
  }
}

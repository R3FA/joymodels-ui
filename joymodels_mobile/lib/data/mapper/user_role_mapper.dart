import 'package:joymodels_mobile/data/model/user_role/user_role_response_api_model.dart';
import 'package:joymodels_mobile/domain/models/user_role/user_role_response.dart';

// Mapper: DATA -> DOMAIN DTO
extension UserRoleResponseApiModelToDomain on UserRoleResponseApiModel {
  UserRoleResponse toDomain() {
    return UserRoleResponse(uuid: uuid, roleName: roleName);
  }
}

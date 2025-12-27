import 'package:http/http.dart' as http;
import 'package:joymodels_mobile/data/core/config/api_constants.dart';
import 'package:joymodels_mobile/data/core/config/token_storage.dart';

class UsersService {
  final String usersUrl = "${ApiConstants.baseUrl}/users";

  Future<http.Response> getByUuid(String userUuid) async {
    final url = Uri.parse("$usersUrl/get/$userUuid");

    final token = await TokenStorage.getAccessToken();

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    return response;
  }
}

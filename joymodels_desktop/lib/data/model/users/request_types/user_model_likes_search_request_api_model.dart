import 'package:joymodels_desktop/data/model/pagination/request_types/pagination_request_api_model.dart';

class UserModelLikesSearchRequestApiModel extends PaginationRequestApiModel {
  final String userUuid;
  final String? modelName;

  UserModelLikesSearchRequestApiModel({
    required this.userUuid,
    this.modelName,
    required super.pageNumber,
    required super.pageSize,
  });

  @override
  Map<String, String> toQueryParameters() {
    return {
      ...super.toQueryParameters(),
      'userUuid': userUuid,
      if (modelName != null) 'modelName': modelName!,
    };
  }
}

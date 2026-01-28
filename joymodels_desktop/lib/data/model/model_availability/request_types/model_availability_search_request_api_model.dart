import 'package:joymodels_desktop/data/model/pagination/request_types/pagination_request_api_model.dart';

class ModelAvailabilitySearchRequestApiModel extends PaginationRequestApiModel {
  final String? availabilityName;

  ModelAvailabilitySearchRequestApiModel({
    this.availabilityName,
    super.pageNumber,
    super.pageSize,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      if (availabilityName != null && availabilityName!.isNotEmpty)
        'availabilityName': availabilityName,
    };
  }
}

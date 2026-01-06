import 'package:joymodels_mobile/data/model/category/response_types/category_response_api_model.dart';
import 'package:joymodels_mobile/data/model/model_availability/response_types/model_availability_response_api_model.dart';
import 'package:joymodels_mobile/data/model/model_picture/response_types/model_picture_response_api_model.dart';
import 'package:joymodels_mobile/data/model/users/response_types/users_response_api_model.dart';

class ModelResponseApiModel {
  final String uuid;
  final String name;
  final String userUuid;
  final DateTime createdAt;
  final String description;
  final double price;
  final String locationPath;
  final UsersResponseApiModel user;
  final ModelAvailabilityResponseApiModel modelAvailability;
  final List<CategoryResponseApiModel> modelCategories;
  final List<ModelPictureResponseApiModel> modelPictures;

  ModelResponseApiModel({
    required this.uuid,
    required this.name,
    required this.userUuid,
    required this.createdAt,
    required this.description,
    required this.price,
    required this.locationPath,
    required this.user,
    required this.modelAvailability,
    required this.modelCategories,
    required this.modelPictures,
  });

  factory ModelResponseApiModel.fromJson(Map<String, dynamic> json) {
    return ModelResponseApiModel(
      uuid: json['uuid'],
      name: json['name'],
      userUuid: json['userUuid'],
      createdAt: DateTime.parse(json['createdAt']),
      description: json['description'],
      price: (json['price']).toDouble(),
      locationPath: json['locationPath'],
      user: UsersResponseApiModel.fromJson(json['user']),
      modelAvailability: ModelAvailabilityResponseApiModel.fromJson(
        json['modelAvailability'],
      ),
      modelCategories: (json['modelCategories'] as List<dynamic>)
          .map((e) => CategoryResponseApiModel.fromJson(e))
          .toList(),
      modelPictures: (json['modelPictures'] as List<dynamic>)
          .map((e) => ModelPictureResponseApiModel.fromJson(e))
          .toList(),
    );
  }
}

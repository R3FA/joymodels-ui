enum ModelAvailabilityEnum { hidden, public }

extension ModelAvailabilityEnumExtension on ModelAvailabilityEnum {
  String get name {
    switch (this) {
      case ModelAvailabilityEnum.hidden:
        return 'Hidden';
      case ModelAvailabilityEnum.public:
        return 'Public';
    }
  }

  static ModelAvailabilityEnum fromString(String value) {
    switch (value.toLowerCase()) {
      case 'hidden':
        return ModelAvailabilityEnum.hidden;
      case 'public':
        return ModelAvailabilityEnum.public;
      default:
        return ModelAvailabilityEnum.public;
    }
  }
}

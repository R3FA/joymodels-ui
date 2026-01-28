class SsoAccessTokenChangeResponseApiModel {
  final String userAccessToken;

  SsoAccessTokenChangeResponseApiModel({required this.userAccessToken});

  factory SsoAccessTokenChangeResponseApiModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return SsoAccessTokenChangeResponseApiModel(
      userAccessToken: json['userAccessToken'] as String,
    );
  }
}

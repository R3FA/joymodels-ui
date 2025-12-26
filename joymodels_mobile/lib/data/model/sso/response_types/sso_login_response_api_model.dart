class SsoLoginResponse {
  final String accessToken;
  final String refreshToken;

  SsoLoginResponse({required this.accessToken, required this.refreshToken});

  factory SsoLoginResponse.fromJson(Map<String, dynamic> json) {
    return SsoLoginResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };
}

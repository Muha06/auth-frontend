class RefreshResponse {
  final String accessToken;
  final String refreshToken;

  RefreshResponse({required this.accessToken, required this.refreshToken});

  factory RefreshResponse.fromJson({required Map<String, dynamic> json}) {
    return RefreshResponse(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
    );
  }
}

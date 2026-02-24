class RefreshtokenLoginRequest {
  final String deviceId;
  final String refreshToken;

  RefreshtokenLoginRequest({
    required this.deviceId,
    required this.refreshToken,
  });

  Map<String, String> toFields() => {
    'deviceId': deviceId,
    'refreshToken': refreshToken,
  };
}

class LoginRequest {
  final String deviceId;
  final String deviceName;
  final String username;
  final String password;

  const LoginRequest({
    required this.deviceId,
    required this.deviceName,
    required this.username,
    required this.password,
  });

  Map<String, String> toFields() => {
    'deviceId': deviceId,
    'deviceName': deviceName,
    'username': username,
    'password': password,
  };
}

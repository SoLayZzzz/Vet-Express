class VerificationRequest {
  String? code;
  String? deviceId;
  String? deviceName;
  String? token;

  VerificationRequest({this.code, this.deviceId, this.deviceName, this.token});

  // Convert JSON Map to RegisterRequest object
  factory VerificationRequest.fromJson(Map<String, dynamic> json) {
    return VerificationRequest(
      code: json['code'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      token: json['token'],
    );
  }

  // Convert RegisterRequest object to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'token': token,
    };
  }
}

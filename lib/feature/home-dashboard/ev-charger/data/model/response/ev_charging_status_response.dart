import 'dart:convert';

EvChargingStatusResponse evChargingStatusResponseFromJson(String str) =>
    EvChargingStatusResponse.fromJson(json.decode(str));

String evChargingStatusResponseToJson(EvChargingStatusResponse data) =>
    json.encode(data.toJson());

class EvChargingStatusResponse {
  Header? header;
  EvChargingStatusBody? body;

  EvChargingStatusResponse({this.header, this.body});

  factory EvChargingStatusResponse.fromJson(Map<String, dynamic> json) =>
      EvChargingStatusResponse(
        header: json["header"] == null ? null : Header.fromJson(json["header"]),
        body:
            json["body"] == null
                ? null
                : EvChargingStatusBody.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body?.toJson(),
  };
}

class EvChargingStatusBody {
  bool? status;
  String? message;
  EvChargingStatusData? data;

  EvChargingStatusBody({this.status, this.message, this.data});

  factory EvChargingStatusBody.fromJson(Map<String, dynamic> json) =>
      EvChargingStatusBody(
        status: json["status"],
        message: json["message"],
        data:
            json["data"] == null
                ? null
                : EvChargingStatusData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class EvChargingStatusData {
  int? isCharging;
  String? chargerUsername;
  String? transactionId;

  EvChargingStatusData({
    this.isCharging,
    this.transactionId,
    this.chargerUsername,
  });

  factory EvChargingStatusData.fromJson(Map<String, dynamic> json) =>
      EvChargingStatusData(
        isCharging: json["isCharging"],
        chargerUsername: json["chargerUsername"],
        transactionId: json["transactionId"],
      );

  Map<String, dynamic> toJson() => {
    "isCharging": isCharging,
    "chargerUsername": chargerUsername,
    "transactionId": transactionId,
  };
}

class Header {
  int? serverTimestamp;
  bool? result;
  int? statusCode;

  Header({this.serverTimestamp, this.result, this.statusCode});

  factory Header.fromJson(Map<String, dynamic> json) => Header(
    serverTimestamp: json["serverTimestamp"],
    result: json["result"],
    statusCode: json["statusCode"],
  );

  Map<String, dynamic> toJson() => {
    "serverTimestamp": serverTimestamp,
    "result": result,
    "statusCode": statusCode,
  };
}

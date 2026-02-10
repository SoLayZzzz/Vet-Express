
import 'dart:convert';

EvWalletAmountResponse evWalletAmountResponseFromJson(String str) => EvWalletAmountResponse.fromJson(json.decode(str));

String evWalletAmountResponseToJson(EvWalletAmountResponse data) => json.encode(data.toJson());

class EvWalletAmountResponse {
  Header? header;
  EvWalletAmountBody? body;

  EvWalletAmountResponse({
    this.header,
    this.body,
  });

  factory EvWalletAmountResponse.fromJson(Map<String, dynamic> json) => EvWalletAmountResponse(
    header: json["header"] == null ? null : Header.fromJson(json["header"]),
    body: json["body"] == null ? null : EvWalletAmountBody.fromJson(json["body"]),
  );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body?.toJson(),
  };
}

class EvWalletAmountBody {
  bool? status;
  String? message;
  double? data;

  EvWalletAmountBody({
    this.status,
    this.message,
    this.data,
  });

  factory EvWalletAmountBody.fromJson(Map<String, dynamic> json) => EvWalletAmountBody(
    status: json["status"],
    message: json["message"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data,
  };
}

class Header {
  int? serverTimestamp;
  bool? result;
  int? statusCode;

  Header({
    this.serverTimestamp,
    this.result,
    this.statusCode,
  });

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

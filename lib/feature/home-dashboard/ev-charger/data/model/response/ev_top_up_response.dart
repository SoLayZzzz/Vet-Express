import 'dart:convert';

EvTopUpResponse evTopUpResponseFromJson(String str) =>
    EvTopUpResponse.fromJson(json.decode(str));

String evTopUpResponseToJson(EvTopUpResponse data) =>
    json.encode(data.toJson());

class EvTopUpResponse {
  Header? header;
  EvTopUpBody? body;

  EvTopUpResponse({this.header, this.body});

  factory EvTopUpResponse.fromJson(Map<String, dynamic> json) =>
      EvTopUpResponse(
        header: json["header"] == null ? null : Header.fromJson(json["header"]),
        body: json["body"] == null ? null : EvTopUpBody.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body?.toJson(),
  };
}

class EvTopUpBody {
  bool? status;
  String? message;
  String? transactionId;
  int? paymentStatus;
  EvTopUpData? data;

  EvTopUpBody({
    this.status,
    this.message,
    this.transactionId,
    this.paymentStatus,
    this.data,
  });

  factory EvTopUpBody.fromJson(Map<String, dynamic> json) => EvTopUpBody(
    status: json["status"],
    message: json["message"],
    transactionId: json["transactionId"],
    paymentStatus: json["paymentStatus"],
    data: json["data"] == null ? null : EvTopUpData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "transactionId": transactionId,
    "paymentStatus": paymentStatus,
    "data": data?.toJson(),
  };
}

class EvTopUpData {
  String? transactionId;
  double? amount;
  int? status;
  String? deeplink;
  String? qrString;
  String? checkoutQrUrl;
  int? paymentStatusCode;
  String? paymentStatus;

  EvTopUpData({
    this.transactionId,
    this.amount,
    this.status,
    this.deeplink,
    this.qrString,
    this.checkoutQrUrl,
    this.paymentStatusCode,
    this.paymentStatus,
  });

  factory EvTopUpData.fromJson(Map<String, dynamic> json) => EvTopUpData(
    transactionId: json["transactionId"],
    amount: json["amount"],
    status: json["status"],
    deeplink: json["deeplink"],
    qrString: json["qrString"],
    checkoutQrUrl: json["checkoutQrUrl"],
    paymentStatusCode: json["paymentStatusCode"],
    paymentStatus: json["paymentStatus"],
  );

  Map<String, dynamic> toJson() => {
    "transactionId": transactionId,
    "amount": amount,
    "status": status,
    "deeplink": deeplink,
    "qrString": qrString,
    "checkoutQrUrl": checkoutQrUrl,
    "paymentStatusCode": paymentStatusCode,
    "paymentStatus": paymentStatus,
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

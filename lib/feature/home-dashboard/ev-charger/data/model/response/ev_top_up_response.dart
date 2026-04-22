import 'dart:convert';

EvTopUpResponse evTopUpResponseFromJson(String str) =>
    EvTopUpResponse.fromJson(json.decode(str));

String evTopUpResponseToJson(EvTopUpResponse data) =>
    json.encode(data.toJson());

class EvTopUpResponse {
  Header? header;
  EvTopUpBody? body;

  EvTopUpResponse({this.header, this.body});

  @override
  String toString() => jsonEncode(toJson());

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

  @override
  String toString() => jsonEncode(toJson());

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
  int? paymentMethod;
  String? checkoutHtml;
  String? deeplink;
  String? paymentTokenid;
  String? coreRefNum;
  String? qrImage;
  String? qrString;
  String? checkoutQrUrl;
  int? paymentStatusCode;
  String? paymentStatus;
  String? appStore;
  String? playStore;

  EvTopUpData({
    this.transactionId,
    this.amount,
    this.status,
    this.paymentMethod,
    this.checkoutHtml,
    this.deeplink,
    this.paymentTokenid,
    this.coreRefNum,
    this.qrImage,
    this.qrString,
    this.checkoutQrUrl,
    this.paymentStatusCode,
    this.paymentStatus,
    this.appStore,
    this.playStore,
  });

  factory EvTopUpData.fromJson(Map<String, dynamic> json) => EvTopUpData(
    transactionId: json["transactionId"],
    amount: (json["amount"] as num?)?.toDouble(),
    status: json["status"],
    paymentMethod: json["paymentMethod"],
    checkoutHtml: json["checkoutHtml"],
    deeplink: json["deeplink"],
    paymentTokenid: json["paymentTokenid"],
    coreRefNum: json["coreRefNum"],
    qrImage: json["qrImage"],
    qrString: json["qrString"],
    checkoutQrUrl: json["checkoutQrUrl"],
    paymentStatusCode: json["paymentStatusCode"],
    paymentStatus: json["paymentStatus"],
    appStore: json["appStore"],
    playStore: json["playStore"],
  );

  @override
  String toString() => jsonEncode(toJson());

  Map<String, dynamic> toJson() => {
    "transactionId": transactionId,
    "amount": amount,
    "status": status,
    "paymentMethod": paymentMethod,
    "checkoutHtml": checkoutHtml,
    "deeplink": deeplink,
    "paymentTokenid": paymentTokenid,
    "coreRefNum": coreRefNum,
    "qrImage": qrImage,
    "qrString": qrString,
    "checkoutQrUrl": checkoutQrUrl,
    "paymentStatusCode": paymentStatusCode,
    "paymentStatus": paymentStatus,
    "appStore": appStore,
    "playStore": playStore,
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

  @override
  String toString() => jsonEncode(toJson());

  Map<String, dynamic> toJson() => {
    "serverTimestamp": serverTimestamp,
    "result": result,
    "statusCode": statusCode,
  };
}

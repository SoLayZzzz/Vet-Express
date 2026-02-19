
import 'dart:convert';

EvScanQrResponse evScanQrResponseFromJson(String str) => EvScanQrResponse.fromJson(json.decode(str));

String evScanQrResponseToJson(EvScanQrResponse data) => json.encode(data.toJson());

class EvScanQrResponse {
  Header? header;
  EvScanQrBody? body;

  EvScanQrResponse({
    this.header,
    this.body,
  });

  factory EvScanQrResponse.fromJson(Map<String, dynamic> json) => EvScanQrResponse(
    header: json["header"] == null ? null : Header.fromJson(json["header"]),
    body: json["body"] == null ? null : EvScanQrBody.fromJson(json["body"]),
  );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body?.toJson(),
  };
}

class EvScanQrBody {
  bool? status;
  String? message;
  List<Datum>? data;

  EvScanQrBody({
    this.status,
    this.message,
    this.data,
  });

  factory EvScanQrBody.fromJson(Map<String, dynamic> json) => EvScanQrBody(
    status: json["status"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  int? id;
  String? orderDate;
  int? isFullCharge;
  int? stationId;
  String? stationName;
  int? chargerId;
  String? chargerName;
  String? soCode;
  String? transactionId;
  int? paymentStatus;
  int? orderStatus;
  double? totalKwh;
  double? totalPrice;
  String? qrString;

  Datum({
    this.id,
    this.orderDate,
    this.isFullCharge,
    this.stationId,
    this.stationName,
    this.chargerId,
    this.chargerName,
    this.soCode,
    this.transactionId,
    this.paymentStatus,
    this.orderStatus,
    this.totalKwh,
    this.totalPrice,
    this.qrString,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    orderDate: json["orderDate"],
    isFullCharge: json["isFullCharge"],
    stationId: json["stationId"],
    stationName: json["stationName"],
    chargerId: json["chargerId"],
    chargerName: json["chargerName"],
    soCode: json["soCode"],
    transactionId: json["transactionId"],
    paymentStatus: json["paymentStatus"],
    orderStatus: json["orderStatus"],
    totalKwh: json["totalKwh"],
    totalPrice: json["totalPrice"],
    qrString: json["qrString"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "orderDate": orderDate,
    "isFullCharge": isFullCharge,
    "stationId": stationId,
    "stationName": stationName,
    "chargerId": chargerId,
    "chargerName": chargerName,
    "soCode": soCode,
    "transactionId": transactionId,
    "paymentStatus": paymentStatus,
    "orderStatus": orderStatus,
    "totalKwh": totalKwh,
    "totalPrice": totalPrice,
    "qrString": qrString,
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

// To parse this JSON data, do
//
//     final evStationListResponse = evStationListResponseFromJson(jsonString);

import 'dart:convert';

EvStationListResponse evStationListResponseFromJson(String str) =>
    EvStationListResponse.fromJson(json.decode(str));

String evStationListResponseToJson(EvStationListResponse data) =>
    json.encode(data.toJson());

class EvStationListResponse {
  Header? header;
  EvStationListBody? body;

  EvStationListResponse({this.header, this.body});

  factory EvStationListResponse.fromJson(Map<String, dynamic> json) =>
      EvStationListResponse(
        header: json["header"] == null ? null : Header.fromJson(json["header"]),
        body:
            json["body"] == null
                ? null
                : EvStationListBody.fromJson(json["body"]),
      );

  Map<String, dynamic> toJson() => {
    "header": header?.toJson(),
    "body": body?.toJson(),
  };
}

class EvStationListBody {
  bool? status;
  String? message;
  List<EvStationListDatum>? data;

  EvStationListBody({this.status, this.message, this.data});

  factory EvStationListBody.fromJson(Map<String, dynamic> json) =>
      EvStationListBody(
        status: json["status"],
        message: json["message"],
        data:
            json["data"] == null
                ? []
                : List<EvStationListDatum>.from(
                  json["data"]!.map((x) => EvStationListDatum.fromJson(x)),
                ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data":
        data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class EvStationListDatum {
  int? id;
  String? code;
  int? companyId;
  int? provinceId;
  int? totalCharger;
  int? totalChargerAvailable;
  String? name;
  double? pricePerKwh;
  String? phoneNumber;
  String? description;
  String? address;
  String? imageUrl;
  String? imageName;
  String? lats;
  String? longs;
  String? value;
  bool? isFavorite;
  bool? isOpen;
  List<EvStationGunInform>? gunInform;

  EvStationListDatum({
    this.id,
    this.code,
    this.companyId,
    this.provinceId,
    this.totalCharger,
    this.totalChargerAvailable,
    this.name,
    this.pricePerKwh,
    this.phoneNumber,
    this.description,
    this.address,
    this.imageUrl,
    this.imageName,
    this.lats,
    this.longs,
    this.value,
    this.isFavorite,
    this.isOpen,
    this.gunInform,
  });

  factory EvStationListDatum.fromJson(Map<String, dynamic> json) =>
      EvStationListDatum(
        id: json["id"],
        code: json["code"],
        companyId: json["companyId"],
        provinceId: json["provinceId"],
        totalCharger: json["totalCharger"],
        totalChargerAvailable: json["totalChargerAvailable"],
        name: json["name"],
        pricePerKwh: (json["pricePerKwh"] as num?)?.toDouble(),
        phoneNumber: json["phoneNumber"],
        description: json["description"],
        address: json["address"],
        imageUrl: json["imageUrl"],
        imageName: json["imageName"],
        lats: json["lats"]?.toString(),
        longs: json["longs"]?.toString(),
        value: json["value"]?.toString(),
        isFavorite: json["isFavorite"],
        isOpen: json["isOpen"],
        gunInform:
            json["gunInform"] == null
                ? []
                : List<EvStationGunInform>.from(
                  json["gunInform"]!.map(
                    (x) => EvStationGunInform.fromJson(x),
                  ),
                ),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "companyId": companyId,
    "provinceId": provinceId,
    "totalCharger": totalCharger,
    "totalChargerAvailable": totalChargerAvailable,
    "name": name,
    "pricePerKwh": pricePerKwh,
    "phoneNumber": phoneNumber,
    "description": description,
    "address": address,
    "imageUrl": imageUrl,
    "imageName": imageName,
    "lats": lats,
    "longs": longs,
    "value": value,
    "isFavorite": isFavorite,
    "isOpen": isOpen,
    "gunInform":
        gunInform == null
            ? []
            : List<dynamic>.from(gunInform!.map((x) => x.toJson())),
  };
}

class EvStationGunInform {
  String? name;
  int? qty;
  int? qtyAvailable;

  EvStationGunInform({this.name, this.qty, this.qtyAvailable});

  factory EvStationGunInform.fromJson(Map<String, dynamic> json) =>
      EvStationGunInform(
        name: json["name"],
        qty: json["qty"] ?? json["amount"],
        qtyAvailable: json["qtyAvailable"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "qty": qty,
    "qtyAvailable": qtyAvailable,
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
